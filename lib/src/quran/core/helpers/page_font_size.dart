part of '/quran.dart';

/// Helpers to compute dynamic font sizes for Quran pages across devices.
class PageFontSizeHelper {
  // Design width used in ScreenUtilInit
  static const double _designWidth = 392.72727272727275;

  /// Compute dynamic font size for QCF (downloaded fonts) pages.
  /// - Uses Layout constraints width when available, else MediaQuery width.
  /// - Adjusts for orientation and clamps to reasonable bounds.
  static double qcfFontSize({
    required BuildContext context,
    required int pageIndex,
    double? maxWidth,
  }) {
    final media = MediaQuery.of(context);
    final width =
        (maxWidth != null && maxWidth > 0) ? maxWidth : media.size.width;
    final orientation = media.orientation;

    double ratio = (width / _designWidth).clamp(0.6, 1.6);
    double size = 100.0 * ratio;

    // In landscape we usually need a smaller size to avoid overflow
    if (orientation == Orientation.landscape) {
      size *= 0.82;
    }

    // Minor adjustment for the first two pages (Fatihah/Baqarah start)
    if (pageIndex == 0 || pageIndex == 1) {
      size *= 0.96;
    }

    // Clamp to safe bounds
    return size.clamp(38.0, 50.0);
  }

  /// Compute dynamic base font size for Hafs (text-scale mode).
  static double hafsFontSize({
    required BuildContext context,
    double? maxWidth,
  }) {
    final media = MediaQuery.of(context);
    final width =
        (maxWidth != null && maxWidth > 0) ? maxWidth : media.size.width;
    final orientation = media.orientation;

    double ratio = (width / _designWidth).clamp(0.6, 1.6);
    double base = 22.0 * ratio;
    if (orientation == Orientation.landscape) base *= 0.9;
    return base.clamp(16.0, 48.0);
  }

  static double getFontSize(int pageIndex, BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // تحويل pageIndex لرقم الصفحة الفعلي (مكنون يبدأ من 1)
    final page = pageIndex + 1;

    // للوضع الأفقي
    if (!isPortrait) {
      return 35.sp;
    }

    // للأجهزة اللوحية أو الشاشات الكبيرة
    if (MediaQuery.of(context).size.shortestSide > 600) {
      return 15.sp;
    }

    // للشاشات الصغيرة
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return 20.sp;
    }

    // الصفحة الأولى والثانية
    if (page == 1 || page == 2) {
      return 25.sp;
    }

    // صفحات خاصة تحتاج أحجام مخصصة
    if (page == 145 || page == 585) {
      return 22.7.sp;
    }

    if (page == 532 || page == 533 || page == 523 || page == 577) {
      return 22.5.sp;
    }

    if (page == 116 || page == 156) {
      return 23.4.sp;
    }

    // مجموعة صفحات بحجم 23.sp
    final size23Pages = [
      56,
      57,
      368,
      269,
      372,
      376,
      409,
      435,
      444,
      448,
      527,
      535,
      565,
      566,
      569,
      574,
      578,
      581,
      584,
      587,
      589,
      590,
      592,
      593,
      50,
      568,
      34
    ];
    if (size23Pages.contains(page)) {
      return 23.sp;
    }

    if (page == 70) {
      return 23.5.sp;
    }

    if (page == 51 || page == 501) {
      return 23.7.sp;
    }

    if (page == 575) {
      return 23.sp;
    }

    // مجموعة صفحات بحجم 22.8.sp
    final size228Pages = [576, 567, 371, 446, 447];
    if (size228Pages.contains(page)) {
      return 22.8.sp;
    }

    // الحجم الافتراضي - مطابق لمكنون
    return 23.1.sp;
  }
}

/// One size for a mushaf page on every screen: its lines are laid out at
/// [lineFontSize] and the whole page is then fitted to its box (one page
/// or two, phone, tablet, desktop, any orientation). The surah frame, its
/// name and the basmala are given in the same units — so they keep their
/// place against the lines everywhere.
///
/// (Upstream picked a line size per device and orientation, `23.1.sp` on a
/// phone, `15.sp` on a tablet, 100 in landscape, and the headers did not
/// follow: too big on tablets, tiny on a wide single page.)
abstract final class QuranPageScale {
  /// The lines' font size before the page is fitted to its box.
  static const double lineFontSize = 100;

  /// Header styles given for [lineFontSize], drawn beside text of [fontSize]
  /// (the flowing, zoomed page).
  static double factorFor(double fontSize) => fontSize / lineFontSize;
}

extension QuranPageScaleBasmala on BasmalaStyle {
  BasmalaStyle scaledBy(double k) => BasmalaStyle(
        basmalaColor: basmalaColor,
        basmalaFontSize: basmalaFontSize == null ? null : basmalaFontSize! * k,
        verticalPadding: verticalPadding == null ? null : verticalPadding! * k,
      );
}

extension QuranPageScaleSurahName on SurahNameStyle {
  SurahNameStyle scaledBy(double k) => SurahNameStyle(
        surahNameColor: surahNameColor,
        surahNameSize: surahNameSize == null ? null : surahNameSize! * k,
      );
}

extension QuranPageScaleBanner on BannerStyle {
  BannerStyle scaledBy(double k) => copyWith(
        bannerSvgWidth: bannerSvgWidth == null ? null : bannerSvgWidth! * k,
        bannerSvgHeight: bannerSvgHeight == null ? null : bannerSvgHeight! * k,
        bannerImageHeight:
            bannerImageHeight == null ? null : bannerImageHeight! * k,
      );
}
