class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  static const String imagesUpload = '/images/upload';
  static const String imagesGet = '/images';

  static const String generateSticker = '/generate/sticker';
  static const String generateAvatar = '/generate/avatar';
  static const String generateHistory = '/generate/history';

  static const Duration timeout = Duration(seconds: 30);
}
