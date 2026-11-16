part of '/quran.dart';

/// ويدجت مساعدة للحفاظ على الصفحة حيّة ضمن PageView
/// One page of a page view (himma_quran).
///
/// - Built at once only if it is the page on screen; the ones around it are
///   built after the turn has stopped, one at a time between frames, the
///   nearest first — a page turn never builds a page in its own frames
///   (quran_library built the page two ahead in the middle of the slide:
///   a 50–70 ms frame on each new page).
/// - Kept alive only within [_keepWithin] pages of the one on screen —
///   quran_library kept every page ever opened (memory growing with each
///   page read, and all of them rebuilt on a theme change).
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({
    required this.index,
    required this.child,
    this.pagesPerItem = 1,
  });

  /// Its place in the page view.
  final int index;

  /// Mushaf pages in one item (2 in the two-page view).
  final int pagesPerItem;
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  static const int _keepWithin = 6;

  /// A page was built (or re-themed) for the coming frame: the next one
  /// waits for the frame after — idle tasks run back to back between two
  /// frames, so without this every waiting page landed in the same frame.
  static bool _onePending = false;

  ScrollPosition? _position;
  bool _ready = false;

  /// What is drawn: a new page widget (a theme change, new colours) is
  /// taken at once by the page on screen, by the others after it — one
  /// at a time between frames, not all in the frame of the change.
  late Widget _shown = widget.child;

  /// The theme it was drawn with: a page off screen keeps it — its
  /// widgets read the theme, so a theme change would otherwise rebuild
  /// and lay out every page kept (8 or so: 200 ms) in that one frame.
  ThemeData? _shownTheme;
  bool _keep = true;

  /// The page on screen, from the page view's own scroll position (right
  /// after a jump too, before the controller reports the new page).
  int? get _current {
    final p = _position;
    if (p != null &&
        p.hasPixels &&
        p.hasViewportDimension &&
        p.viewportDimension > 0) {
      return (p.pixels / p.viewportDimension).round();
    }
    // The first frame (no position yet): the page the reader opens on.
    return (QuranCtrl.instance.state.currentPageNumber.value - 1) ~/
        widget.pagesPerItem;
  }

  int get _distance {
    final c = _current;
    return c == null ? 0 : (widget.index - c).abs();
  }

  @override
  bool get wantKeepAlive => _keep;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position == _position) return;
    _position?.isScrollingNotifier.removeListener(_scrollingChanged);
    _position = position;
    position?.isScrollingNotifier.addListener(_scrollingChanged);
    if (!_ready) {
      if (_distance == 0) {
        _ready = true;
      } else {
        _buildSoon();
      }
    } else if (_shownTheme != null &&
        !identical(Theme.of(context), _shownTheme)) {
      if (_distance == 0) {
        _shownTheme = Theme.of(context);
      } else {
        _buildSoon();
      }
    }
  }

  @override
  void didUpdateWidget(_KeepAlive old) {
    super.didUpdateWidget(old);
    if (identical(old.child, widget.child)) return;
    if (!_ready || _distance == 0) {
      _shown = widget.child;
      _shownTheme = Theme.of(context);
    } else {
      _buildSoon();
    }
  }

  @override
  void dispose() {
    _position?.isScrollingNotifier.removeListener(_scrollingChanged);
    super.dispose();
  }

  void _scrollingChanged() {
    if (_position?.isScrollingNotifier.value ?? false) return;
    // Stopped: still near enough to keep?
    final keep = _distance <= _keepWithin;
    if (keep != _keep) {
      _keep = keep;
      updateKeepAlive();
    }
  }

  /// Between frames, with nothing animating or scrolling — nearest first.
  void _buildSoon() {
    final nearness = (_keepWithin - _distance).clamp(0, _keepWithin);
    SchedulerBinding.instance.scheduleTask<void>(() {
      if (!mounted ||
          (_ready &&
              identical(_shown, widget.child) &&
              identical(_shownTheme, Theme.of(context)))) {
        return;
      }
      if (_position?.isScrollingNotifier.value ?? false) {
        // Turning: after it stops (see [_scrollingChanged] → here again).
        void stopped() {
          if (_position?.isScrollingNotifier.value ?? false) return;
          _position?.isScrollingNotifier.removeListener(stopped);
          if (mounted) _buildSoon();
        }

        _position?.isScrollingNotifier.addListener(stopped);
        return;
      }
      if (_onePending) {
        SchedulerBinding.instance.endOfFrame.then((_) {
          if (mounted) _buildSoon();
        });
        return;
      }
      _onePending = true;
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _onePending = false);
      setState(() {
        _ready = true;
        _shown = widget.child;
        _shownTheme = Theme.of(context);
      });
    }, Priority.idle + nearness);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Not built yet: the page's own background shows (it is off screen,
    // or a fast fling passed it — built as soon as the fling stops).
    if (!_ready) return const SizedBox.expand();
    final theme = Theme.of(context);
    return Theme(data: _shownTheme ??= theme, child: _shown);
  }
}

class PageViewBuild extends StatelessWidget {
  const PageViewBuild({
    super.key,
    required this.circularProgressWidget,
    required this.languageCode,
    required this.bookmarkList,
    required this.ayahSelectedFontColor,
    required this.textColor,
    required this.ayahIconColor,
    required this.showAyahBookmarkedIcon,
    required this.onAyahLongPress,
    required this.bookmarksColor,
    this.customBookmarksColor,
    required this.surahNameStyle,
    required this.bannerStyle,
    required this.basmalaStyle,
    required this.onSurahBannerPress,
    required this.surahNumber,
    required this.ayahSelectedBackgroundColor,
    required this.onPagePress,
    required this.isDark,
    required this.fontsName,
    required this.ayahBookmarked,
    this.isAyahBookmarked,
    required this.userContext,
    required this.pageIndex,
    required this.quranCtrl,
    required this.isFontsLocal,
  });

  final Widget? circularProgressWidget;
  final String? languageCode;
  final List bookmarkList;
  final Color? ayahSelectedFontColor;
  final Color? textColor;
  final Color? ayahIconColor;
  final bool showAyahBookmarkedIcon;
  final void Function(LongPressStartDetails details, AyahModel ayah)?
      onAyahLongPress;
  final Color? bookmarksColor;
  final Color? Function(AyahModel)? customBookmarksColor;
  final SurahNameStyle? surahNameStyle;
  final BannerStyle? bannerStyle;
  final BasmalaStyle? basmalaStyle;
  final void Function(SurahNamesModel surah)? onSurahBannerPress;
  final int? surahNumber;
  final Color? ayahSelectedBackgroundColor;
  final VoidCallback? onPagePress;
  final bool isDark;
  final String? fontsName;
  final List<int>? ayahBookmarked;
  final bool Function(AyahModel ayah)? isAyahBookmarked;
  final BuildContext userContext;
  final int pageIndex;
  final QuranCtrl quranCtrl;
  final bool isFontsLocal;

  @override
  Widget build(BuildContext context) {
    // استخدام سياق المستخدم / Using user context
    // تحضير مجموعات وبيانات ثابتة لتقليل الحسابات داخل البناء الداخلي
    final bookmarksCtrl = BookmarksCtrl.instance;
    final Map<int, List<BookmarkModel>> bookmarksMap = bookmarksCtrl.bookmarks;
    final Set<int> bookmarksAyahSet = bookmarksCtrl.bookmarksAyahs.toSet();
    // final bookmarkCtrl = BookmarksCtrl.instance;
    return GetBuilder<QuranCtrl>(
      id: '_pageViewBuild',
      init: QuranCtrl.instance,
      builder: (quranCtrl) {
        if (quranCtrl.state.allAyahs.isEmpty ||
            quranCtrl.surahs.isEmpty ||
            quranCtrl.state.pages.isEmpty) {
          return Center(
            child: circularProgressWidget ?? const CircularProgressIndicator(),
          );
        }

        return Align(
          alignment: Alignment.center,
          child: TopAndBottomWidget(
            pageIndex: pageIndex,
            languageCode: languageCode,
            isRight: pageIndex.isEven,
            child: _QuranFontsPage(
              context: userContext,
              pageIndex: pageIndex,
              bookmarkList: bookmarkList,
              textColor: ayahSelectedFontColor ?? textColor,
              ayahIconColor: ayahIconColor,
              showAyahBookmarkedIcon: showAyahBookmarkedIcon,
              bookmarks: bookmarksMap,
              onAyahLongPress: onAyahLongPress,
              bookmarksColor: bookmarksColor,
              customBookmarksColor: customBookmarksColor,
              surahNameStyle: surahNameStyle,
              bannerStyle: bannerStyle,
              basmalaStyle: basmalaStyle,
              onSurahBannerPress: onSurahBannerPress,
              surahNumber: surahNumber,
              bookmarksAyahs: bookmarksAyahSet.toList(),
              ayahSelectedBackgroundColor: ayahSelectedBackgroundColor,
              isDark: isDark,
              circularProgressWidget: circularProgressWidget,
              isFontsLocal: isFontsLocal,
              fontsName: fontsName,
              ayahBookmarked: ayahBookmarked!,
              isAyahBookmarked: isAyahBookmarked,
              onPagePress: onPagePress,
            ),
          ),
        );
      },
    );
  }
}
