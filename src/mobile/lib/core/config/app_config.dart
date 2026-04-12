/// Configuration de l'application FamilyRoots
class AppConfig {
  // Supabase
  static const String supabaseUrl = 'https://zuvkkoraspuzbblsytvl.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_rFFzm-_35zyHUjhDK5yqYQ_h-MerbFq';
  
  // Backend GraphQL
  static const String graphqlEndpoint = 'http://localhost:4000/graphql';
  
  // Deep Links
  static const String deepLinkScheme = 'familyroots';
  static const String authCallbackPath = 'auth-callback';
  
  // App Info
  static const String appName = 'FamilyRoots';
  static const String appVersion = '1.0.0';
}
