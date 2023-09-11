// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_preferences/shared_preferences.dart';

Future<Preference> initPreference() async {
  Preference pref = Preference._();
  pref._init();
  return pref;
}

class Preference {
  Preference._();

  SharedPreferences? _prefs;

  Future _init() async => _prefs = await SharedPreferences.getInstance();

  
}
