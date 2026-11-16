part of '/quran.dart';

/// Extension to handle font-related operations for the QuranCtrl class.
///
/// الخطوط تُحمّل ديناميكيًا عبر [QuranFontsService] من ملفات `.ttf.gz`
/// مضغوطة في الـ assets.
extension FontsExtension on QuranCtrl {
  /// يُرجع اسم عائلة الخط للصفحة المحددة (page1 .. page604).
  /// في الوضع الداكن مع التجويد يُرجع النسخة الداكنة (page1d .. page604d).
  String getFontPath(int pageIndex, {bool isDark = false}) {
    final withTajweed = state.isTajweedEnabled.value;
    final variant = withTajweed ? (isDark ? 'd' : '') : (isDark ? 'nd' : 'n');
    // himma_quran: loaded on demand (see QuranFontsService.variantFamily).
    return QuranFontsService.variantFamily(pageIndex + 1, variant);
  }

  /// يُرجع اسم عائلة الخط الأحمر لكلمات الخلاف (القراءات العشر).
  String getRedFontPath(int pageIndex) {
    return QuranFontsService.variantFamily(pageIndex + 1, 'nr');
  }

  /// يُرجع اسم عائلة الخط الشفاف لكلمات التسميع المخفية (ألفا 0).
  String getTransparentFontPath(int pageIndex) {
    return QuranFontsService.getTransparentFontFamily(pageIndex);
  }
}
