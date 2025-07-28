class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kahbplmxsmzsxmgfwzqt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImthaGJwbG14c216c3htZ2Z3enF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NDA5OTQsImV4cCI6MjA2OTAxNjk5NH0.bN5xfB83XH14X9UKmsHXRvbRJwHgEkuVM7a7KISbH6M',
  );
}
