part of '../../main.dart';

class LanguageConverter {
  static final list = LanguageList();

  static String convertLanguage(String short) {
    String language = short.split('_')[0];
    return list[language].name;
  }
}
