import 'package:ecommerce_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(localeNotifierProvider);
  final languageCode = locale?.languageCode;
  return languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  void useSystemLocale() => state = null;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    state = locale;
  }

  void setLanguageCode(String languageCode) {
    final locale = AppLocalizations.supportedLocales
        .where((item) => item.languageCode == languageCode)
        .firstOrNull;
    if (locale == null) return;
    state = locale;
  }

  void toggleLocale() {
    final currentLanguage = state?.languageCode ?? 'en';
    setLanguageCode(currentLanguage == 'ar' ? 'en' : 'ar');
  }
}
