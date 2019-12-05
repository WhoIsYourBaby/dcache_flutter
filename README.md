# dcache_flutter

Dcache_flutter is a library for [Dio ( http client for flutter )](https://github.com/flutterchina/dio). Dcache_flutter uses [sqflite](https://github.com/tekartik/sqflite) as disk cache and we consider that memery cache is unnecessary. It is used in our product. It is fully tested and stable. Maybe it's useful for you too.

## Getting Started

### Add dependency

```yaml
dependencies:
  dcache_flutter: 1.0.2 #latest version
```
> dcache 1.0.0 is supported for dio 2.x

### Super simple to use

```dart
import 'package:dcache_flutter/dcache.dart';

final encoder = DCacheEncoder();
final storage = DSqliteStorage(encoder: encoder);
final cacheDefaultOption = DCacheOptions(
    age: Duration(seconds: 120),
    policy: DCachePolicy.refreshFirst,
);
final cacheInterceptor = DCache(
    storage: storage,
    options: cacheDefaultOption,
);
dioInstance.interceptors.add(cacheInterceptor);
```
- DCacheEncoder: Encode and decode the key content of the response. It has a subclass named DBase64Encoder. Of course you can customize the encoder by inheriting DCacheEncoder, such as encryption.
- DSqliteStorage: Store the response in sqlite. You can implement your own storage by inheriting DCacheStorage.
- DCacheOptions: Provide age and policy of the cache.
- DCachePolicy: Provide 3 kind of policy.
    - .cacheFirst: Use cache data first, if the cache data does not exist, then make the request.
    - .refreshFirst: Make request first, if the request returns an error, the cache is used.
    - .justRefresh: Just make request, and the response will be cached.
- DCache: A subclass of Interceptor. So we can add it into dioInstance.interceptors.

### Set different options for each request.

```dart
final cacheOption = DCacheOptions(
    policy: DCachePolicy.cacheFirst,
);
final dioOptions = Options();
dioOptions.extra = cacheOption.toJson();
dioInstance().getUri(uri, options: dioOptions)
```

### Features and bugs
Please file feature requests and bugs at the issue tracker.