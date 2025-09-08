import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberEmailKey = 'remember_email';

  // Guardar email recordado
  static Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedEmailKey, email);
    await prefs.setBool(_rememberEmailKey, true);
  }

  // Obtener email recordado
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberEmail = prefs.getBool(_rememberEmailKey) ?? false;
    if (rememberEmail) {
      return prefs.getString(_rememberedEmailKey);
    }
    return null;
  }

  // Verificar si debe recordar email
  static Future<bool> shouldRememberEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberEmailKey) ?? false;
  }

  // Limpiar email recordado
  static Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberedEmailKey);
    await prefs.setBool(_rememberEmailKey, false);
  }
}
