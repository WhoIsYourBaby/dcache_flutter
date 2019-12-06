
import 'package:dio/dio.dart';
import 'package:dcache_flutter/dcache.dart';

class DioManager {
  static Dio _dioInstance;

  static Dio getInstance() {
    if (_dioInstance == null) {
      // default contentType is json.
      final opt = BaseOptions();
      _dioInstance = Dio(opt);
      // _dioInstance.httpClientAdapter = DefaultHttpClientAdapter()
      //   ..onHttpClientCreate = (client) {
      //     client.findProxy = (uri) => 'PROXY 192.168.7.40:8888';
      //   };
      final encoder = DCacheEncoder();
      final storage = DSqliteStorage(encoder: encoder);
      // Refresh data from server every time by default.
      final cacheDefaultOption = DCacheOptions(
        age: Duration(seconds: 120),
        policy: DCachePolicy.justRefresh,
      );
      final cacheInterceptor = DCache(
        storage: storage,
        options: cacheDefaultOption,
        ignoreFunc: (response) {
          String resultcode = '200';  //the code of response.data
          if (response.data is Map) {
            resultcode = response.data['resultcode'];
          }
          return response.statusCode != 200 || resultcode != '200';
        }
      );
      _dioInstance.interceptors.add(cacheInterceptor);
    }
    return _dioInstance;
  }
}
