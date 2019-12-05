import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'dcache_options.dart';
import 'dcache_storage.dart';

export 'dcache_options.dart';
export 'dcache_encoder.dart';
export 'dcache_storage.dart';

/// A cache management fir dio based on request.
class DCache extends Interceptor {
  // the default option for request
  DCacheOptions options;
  final DCacheStorage storage;
  bool Function(Response resp) ignoreFunc;
  DCache({
    this.options,
    this.storage,
    this.ignoreFunc,
  })  : assert(options != null),
        assert(storage != null),
        super() {
    if (this.ignoreFunc == null) {
      this.ignoreFunc = (Response resp) {
        return false;
      };
    }
  }

  @override
  FutureOr<dynamic> onRequest(RequestOptions options) async {
    String key = getKeyOf(options);
    final optOfRequest = DCacheOptions.fromJson(options.extra);
    final optMerged = this.options.merge(optOfRequest);
    if ((optMerged.policy ?? DCachePolicy.justRefresh) ==
        DCachePolicy.cacheFirst) {
      final resp = await storage.getResponse(key: key);
      if (resp != null) {
        resp.request = options;
        return resp;
      }
    }
    return super.onRequest(options);
  }

  @override
  FutureOr<dynamic> onResponse(Response response) {
    if (this.ignoreFunc(response)) {
      return response;
    }
    String key = getKeyOf(response.request);
    final optOfRequest = DCacheOptions.fromJson(response.extra);
    final optMerged = this.options.merge(optOfRequest);
    this.storage.setResponse(
        key: key, response: response, age: optMerged.age ?? Duration(days: 1));
    return response;
  }

  @override
  FutureOr<dynamic> onError(DioError err) async {
    final key = getKeyOf(err.request);
    final optOfRequest = DCacheOptions.fromJson(err.request.extra);
    final optMerged = this.options.merge(optOfRequest);
    if ((optMerged.policy ?? DCachePolicy.justRefresh) ==
        DCachePolicy.refreshFirst) {
      final resp = await storage.getResponse(key: key);
      if (resp != null) {
        resp.request = err.request;
        return resp;
      }
    }
    return super.onError(err);
  }

  String getKeyOf(RequestOptions options) {
    String key = options.method +
        ':' +
        options.uri.toString() +
        (options.data.toString() ?? '');
    final enc = md5.convert(utf8.encode(key)).toString();
    return enc;
  }
}
