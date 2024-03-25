// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class Localize {
  Localize();

  static Localize? _current;

  static Localize get current {
    assert(_current != null,
        'No instance of Localize was loaded. Try to initialize the Localize delegate before accessing Localize.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<Localize> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = Localize();
      Localize._current = instance;

      return instance;
    });
  }

  static Localize of(BuildContext context) {
    final instance = Localize.maybeOf(context);
    assert(instance != null,
        'No instance of Localize present in the widget tree. Did you add Localize.delegate in localizationsDelegates?');
    return instance!;
  }

  static Localize? maybeOf(BuildContext context) {
    return Localizations.of<Localize>(context, Localize);
  }

  /// `English Study Daily Notification`
  String get notification_title_daily {
    return Intl.message(
      'English Study Daily Notification',
      name: 'notification_title_daily',
      desc: '',
      args: [],
    );
  }

  /// `Open app to learn`
  String get notification_body_daily {
    return Intl.message(
      'Open app to learn',
      name: 'notification_body_daily',
      desc: '',
      args: [],
    );
  }

  /// `Vocabulary`
  String get main_screen_tab_vocabulary_title {
    return Intl.message(
      'Vocabulary',
      name: 'main_screen_tab_vocabulary_title',
      desc: '',
      args: [],
    );
  }

  /// `Listen`
  String get main_screen_tab_listen_title {
    return Intl.message(
      'Listen',
      name: 'main_screen_tab_listen_title',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get main_screen_tab_complete_title {
    return Intl.message(
      'Complete',
      name: 'main_screen_tab_complete_title',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get main_screen_tab_setting_title {
    return Intl.message(
      'Setting',
      name: 'main_screen_tab_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Learned topics`
  String get category_component_title_complete {
    return Intl.message(
      'Learned topics',
      name: 'category_component_title_complete',
      desc: '',
      args: [],
    );
  }

  /// `Please choose a category to get started`
  String get category_component_title_learn {
    return Intl.message(
      'Please choose a category to get started',
      name: 'category_component_title_learn',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get category_component_button_select {
    return Intl.message(
      'Select',
      name: 'category_component_button_select',
      desc: '',
      args: [],
    );
  }

  /// `Download all lession`
  String get topic_component_text_download {
    return Intl.message(
      'Download all lession',
      name: 'topic_component_text_download',
      desc: '',
      args: [],
    );
  }

  /// `You need to study the open topics first`
  String get topic_component_text_warning_complete {
    return Intl.message(
      'You need to study the open topics first',
      name: 'topic_component_text_warning_complete',
      desc: '',
      args: [],
    );
  }

  /// `You must download data lession first`
  String get topic_component_text_warning_need_download {
    return Intl.message(
      'You must download data lession first',
      name: 'topic_component_text_warning_need_download',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during the download process`
  String get topic_component_text_download_error {
    return Intl.message(
      'An error occurred during the download process',
      name: 'topic_component_text_download_error',
      desc: '',
      args: [],
    );
  }

  /// `Learn Another Topic`
  String get topic_component_text_another_category {
    return Intl.message(
      'Learn Another Topic',
      name: 'topic_component_text_another_category',
      desc: '',
      args: [],
    );
  }

  /// `Download this lession`
  String get sub_topic_component_text_download {
    return Intl.message(
      'Download this lession',
      name: 'sub_topic_component_text_download',
      desc: '',
      args: [],
    );
  }

  /// `Learn Another Topic`
  String get sub_topic_component_text_another_category {
    return Intl.message(
      'Learn Another Topic',
      name: 'sub_topic_component_text_another_category',
      desc: '',
      args: [],
    );
  }

  /// `You need to study the open topics first`
  String get sub_topic_component_text_warning_complete {
    return Intl.message(
      'You need to study the open topics first',
      name: 'sub_topic_component_text_warning_complete',
      desc: '',
      args: [],
    );
  }

  /// `You must download data lession first`
  String get sub_topic_component_text_warning_need_download {
    return Intl.message(
      'You must download data lession first',
      name: 'sub_topic_component_text_warning_need_download',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during the download process`
  String get sub_topic_component_text_download_error {
    return Intl.message(
      'An error occurred during the download process',
      name: 'sub_topic_component_text_download_error',
      desc: '',
      args: [],
    );
  }

  /// `You can play games to learn vocabulary more effectively`
  String get flash_card_screen_text_suggest_play_game {
    return Intl.message(
      'You can play games to learn vocabulary more effectively',
      name: 'flash_card_screen_text_suggest_play_game',
      desc: '',
      args: [],
    );
  }

  /// `View Examples`
  String get vocabulary_component_text_view_example {
    return Intl.message(
      'View Examples',
      name: 'vocabulary_component_text_view_example',
      desc: '',
      args: [],
    );
  }

  /// `View Vocabulary`
  String get example_component_text_view_vocabulary {
    return Intl.message(
      'View Vocabulary',
      name: 'example_component_text_view_vocabulary',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get widget_after_game_button_review {
    return Intl.message(
      'Review',
      name: 'widget_after_game_button_review',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get widget_after_game_button_next {
    return Intl.message(
      'Next',
      name: 'widget_after_game_button_next',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<Localize> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<Localize> load(Locale locale) => Localize.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
