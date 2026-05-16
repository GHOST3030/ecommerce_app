class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';

  static void validate() {
    assert(supabaseUrl.isNotEmpty, 'SUPABASE_URL is not defined. Pass it via --dart-define.');
    assert(supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY is not defined. Pass it via --dart-define.');
  }
}
