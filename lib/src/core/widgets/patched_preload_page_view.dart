part of '/quran.dart';

/// نسخة مُعدّلة من [PreloadPageView] تدعم [padEnds].
///
/// الحزمة الأصلية (preload_page_view 0.2.0) لا تمرر `padEnds` إلى
/// [SliverFillViewport]، فالقيمة الافتراضية `true` تُسبب هامشاً يجعل
/// `viewportFraction: 0.5` يعرض 1.5 صفحة بدل 2.
///
/// عند `padEnds: false`، تُعرض الصفحات بدون هامش إضافي.
class PatchedPreloadPageView extends StatefulWidget {
  PatchedPreloadPageView.builder({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PreloadPageController? controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.preloadPagesCount = 1,
    this.padEnds = true,
  })  : controller = controller ?? PreloadPageController(),
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount);

  final Axis scrollDirection;
  final bool reverse;
  final PreloadPageController controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final ValueChanged<int>? onPageChanged;
  final SliverChildDelegate childrenDelegate;
  final int preloadPagesCount;

  /// عند false، لا يُضاف هامش قبل أول عنصر وبعد آخر عنصر.
  final bool padEnds;

  @override
  State<PatchedPreloadPageView> createState() => _PatchedPreloadPageViewState();
}

class _PatchedPreloadPageViewState extends State<PatchedPreloadPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics? physics = widget.pageSnapping
        ? const PageScrollPhysics().applyTo(widget.physics)
        : widget.physics;

    final int preload = widget.preloadPagesCount;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          // نستخدم controller.page مباشرة بدل PageMetrics لتجنب
          // تعارض الأسماء بين Flutter و preload_page_view
          final int currentPage =
              widget.controller.page?.round() ?? _lastReportedPage;
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged!(currentPage);
          }
        }
        return false;
      },
      child: Scrollable(
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            scrollCacheExtent: ScrollCacheExtent.pixels(preload < 1
                ? 0
                : (preload == 1
                    ? 1
                    : widget.scrollDirection == Axis.horizontal
                        ? MediaQuery.of(context).size.width * preload - 1
                        : MediaQuery.of(context).size.height * preload - 1)),
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                viewportFraction: widget.controller.viewportFraction,
                padEnds: widget.padEnds,
                delegate: widget.childrenDelegate,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The mushaf's page controller, which may hold more than one page view at
/// a time: a mushaf kept in a tab under a screen that opens another one
/// (e.g. a parent's «في المصحف»). The base controller asserts one view and
/// threw "Too many elements" on a jump — the page never moved. Here a jump
/// moves every view, and the page is read from the newest (on top).
class QuranPagesController extends PreloadPageController {
  QuranPagesController({
    super.initialPage,
    super.keepPage,
    super.viewportFraction,
  });

  /// The view attached last: the screen on top.
  ScrollPosition get _shown => positions.last;

  double _pixelsOf(ScrollPosition p, int page) =>
      page * p.viewportDimension * viewportFraction;

  @override
  double? get page {
    if (!hasClients) return null;
    final p = _shown;
    if (!p.hasPixels || !p.hasViewportDimension || !p.hasContentDimensions) {
      return null;
    }
    return math.max(0.0, p.pixels.clamp(p.minScrollExtent, p.maxScrollExtent)) /
        math.max(1.0, p.viewportDimension * viewportFraction);
  }

  @override
  void jumpToPage(int page) {
    for (final p in positions.toList()) {
      if (p.hasViewportDimension) p.jumpTo(_pixelsOf(p, page));
    }
  }

  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    final shown = _shown;
    for (final p in positions.toList()) {
      if (!identical(p, shown) && p.hasViewportDimension) {
        p.jumpTo(_pixelsOf(p, page));
      }
    }
    if (!shown.hasViewportDimension) return Future.value();
    return shown.animateTo(
      _pixelsOf(shown, page),
      duration: duration,
      curve: curve,
    );
  }
}
