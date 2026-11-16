// import 'dart:math';

// import 'package:himma_quran/quran.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class QuranSearch {
//   final List<AyahModel> ayahs;
//   late Interpreter interpreter;
//   late List<List<double>> ayahEmbeddings;

//   QuranSearch(this.ayahs) {
//     loadModel();
//     _computeAyahEmbeddings();
//   }

//   void checkModelInputs() {
//     final inputShape = interpreter.getInputTensor(0).shape;
//     final outputShape = interpreter.getOutputTensor(0).shape;
//     print("🔍 Input Shape: $inputShape");
//     print("🔍 Output Shape: $outputShape");
//   }

//   // تحميل نموذج Arabic BERT
//   Future<void> loadModel() async {
//     try {
//       interpreter = await Interpreter.fromAsset(
//         'packages/quran_library/assets/arabic_bert.tflite',
//       );

//       // Ensure interpreter is initialized before calling checkModelInputs
//       checkModelInputs();
//     } catch (e) {
//       print("🚨 Error loading model: $e");
//       throw Exception("Failed to load Arabic BERT model");
//     }
//   }

//   // حساب التضمينات لكل آية وحفظها في مصفوفة
//   void _computeAyahEmbeddings() {
//     ayahEmbeddings =
//         ayahs.map((aya) => _getEmbedding(aya.ayaTextEmlaey)).toList();
//   }

//   // استخراج تضمين لنص معين باستخدام النموذج
//   List<double> _getEmbedding(String text) {
//     final input = _preprocessText(text);
//     final output = List<List<List<double>>>.filled(
//         1, List.filled(128, List.filled(32000, 0.0)));

//     interpreter.run(input, output);

//     // Extract CLS token embedding (usually at index [0][0])
//     return output[0][0].sublist(0, 768); // Keep only the first 768 dimensions
//   }

//   // البحث في القرآن باستخدام الطرق التقليدية + البحث الذكي
//   Future<List<AyahModel>> search(String searchText) async {
//     if (searchText.isEmpty) return [];

//     // تطبيع البحث
//     final normalizedSearchText = normalizeText(searchText.toLowerCase().trim());

//     // البحث التقليدي
//     final filteredAyahs = ayahs.where((aya) {
//       final normalizedAyahText = normalizeText(aya.ayaTextEmlaey.toLowerCase());
//       final normalizedSurahNameAr = normalizeText(aya.arabicName.toLowerCase());
//       final normalizedSurahNameEn =
//           normalizeText(aya.englishName.toLowerCase());

//       final containsWord = normalizedAyahText.contains(normalizedSearchText);
//       final matchesPage = aya.page.toString() ==
//           normalizedSearchText
//               .convertArabicNumbersToEnglish(normalizedSearchText);
//       final matchesSurahName = normalizedSurahNameAr == normalizedSearchText ||
//           normalizedSurahNameEn == normalizedSearchText;
//       final matchesAyahNumber = aya.ayahNumber.toString() ==
//           normalizedSearchText
//               .convertArabicNumbersToEnglish(normalizedSearchText);

//       return containsWord ||
//           matchesPage ||
//           matchesSurahName ||
//           matchesAyahNumber;
//     }).toList();

//     // البحث الذكي باستخدام Arabic BERT
//     final searchEmbedding = _getEmbedding(searchText);
//     final List<MapEntry<double, AyahModel>> similarityScores = [];

//     for (int i = 0; i < ayahs.length; i++) {
//       double similarity = _cosineSimilarity(searchEmbedding, ayahEmbeddings[i]);
//       if (similarity > 0.6) {
//         // حد أدنى للتشابه
//         similarityScores.add(MapEntry(similarity, ayahs[i]));
//       }
//     }

//     // ترتيب الآيات حسب أعلى درجة تشابه
//     similarityScores.sort((a, b) => b.key.compareTo(a.key));
//     final smartSearchResults =
//         similarityScores.map((entry) => entry.value).toList();

//     // دمج النتائج
//     return [...filteredAyahs, ...smartSearchResults];
//   }

//   // حساب تشابه كوزاين
//   double _cosineSimilarity(List<double> vec1, List<double> vec2) {
//     double dotProduct = 0, norm1 = 0, norm2 = 0;
//     for (int i = 0; i < vec1.length; i++) {
//       dotProduct += vec1[i] * vec2[i];
//       norm1 += pow(vec1[i], 2);
//       norm2 += pow(vec2[i], 2);
//     }
//     return dotProduct / (sqrt(norm1) * sqrt(norm2));
//   }

//   // تطبيع النصوص
//   String normalizeText(String text) {
//     return text
//         .replaceAll('ة', 'ه')
//         .replaceAll('أ', 'ا')
//         .replaceAll('إ', 'ا')
//         .replaceAll('آ', 'ا')
//         .replaceAll('ى', 'ي')
//         .replaceAll('ئ', 'ي')
//         .replaceAll('ؤ', 'و')
//         .replaceAll(RegExp(r'\s+'), ' ');
//   }

//   // معالجة النص المدخل ليصبح جاهزًا للنموذج
//   List<double> _preprocessText(String text) {
//     // تحويل النص إلى قائمة أرقام تمثل الرموز المميزة (tokens) للنموذج
//     return List<double>.filled(512, 0); // حجم الإدخال للنموذج
//   }
// }
