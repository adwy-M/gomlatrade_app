import 'dart:convert';

class ApiConfig {
  static const String baseUrl = 'https://gomlatrade.com';
  static const String wcApiBase = '$baseUrl/wp-json/wc/v3';
  static const String storeApiBase = '$baseUrl/wp-json/wc/store/v1';

  static const String consumerKey = String.fromEnvironment('WC_CONSUMER_KEY');
  static const String consumerSecret = String.fromEnvironment('WC_CONSUMER_SECRET');

  static bool get hasWooCommerceCredentials =>
      consumerKey.isNotEmpty && consumerSecret.isNotEmpty;

  // Basic Auth header for WC REST API v3
  static String get authHeader {
    final credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    return 'Basic $credentials';
  }

  // Endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  static const String ordersEndpoint = '/orders';

  // Store API endpoints (public, no auth needed)
  static const String storeProducts = '$storeApiBase/products';
  static const String storeCategories = '$storeApiBase/products/categories';
  static const String storeCart = '$storeApiBase/cart';

  // Auth endpoints
  static const String jwtLogin = '$baseUrl/wp-json/jwt-auth/v1/token';
  static const String wcCustomers = '$wcApiBase/customers';
}
