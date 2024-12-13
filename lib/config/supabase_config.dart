import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Supabase 설정이 유효한지 확인
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;

  // 설정 상태 확인용 메소드
  static void validateConfig() {
    if (!isValid) {
      throw Exception(
          'Supabase configuration is invalid. Please check your .env file.');
    }
  }
}
