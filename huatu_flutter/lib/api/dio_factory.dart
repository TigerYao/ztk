import 'package:dio/dio.dart';
import 'api.dart';

class DioFactory {
  static Dio _dio;

  static DioFactory _instance;

  static DioFactory getInstance() {
    if (_instance == null) {
      _instance = new DioFactory._();
      _instance._init();
    }
    return _instance;
  }

  DioFactory._();

  _init() {
    _dio = new Dio();
    _dio.options = BaseOptions(
      baseUrl: Api.BASE_URL,
      connectTimeout: 300000
    );
  }

  getDio() {
    return _dio;
  }
}
