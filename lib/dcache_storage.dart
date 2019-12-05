import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'dcache_encoder.dart';

abstract class DCacheStorage {
  Future<bool> setResponse({String key, Response response, Duration age});

  Future<Response> getResponse({String key});

  clearExpired();

  clearAll();
}

class DSqliteStorage extends DCacheStorage {
  Database _db;
  final DCacheEncoder encoder;
  DSqliteStorage({this.encoder});

  Future<Database> get _database async {
    if (_db == null || _db.isOpen == false) {
      final dirPath = await getDatabasesPath();
      await Directory(dirPath).create(recursive: true);
      final dbPath = dirPath + (dirPath.endsWith('/') ? '.cache' : '/.cache');
      print('DCache path: ' + dbPath);
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          final scache = '''
            CREATE TABLE IF NOT EXISTS dcache (
            key TEXT NOT NULL UNIQUE,
            url	TEXT DEFAULT NULL,
            data BLOB NOT NULL,
            responseType INTEGER NOT NULL,
            header TEXT NOT NULL,
            code INTEGER NOT NULL,
            message TEXT,
            extra TEXT NOT NULL,
            time INTEGER NOT NULL,
            expired INTEGER NOT NULL,
            PRIMARY KEY(key)
            );
          ''';
          await db.execute(scache);
        },
      );
    }
    return _db;
  }

  @override
  clearAll() async {
    final db = await this._database;
    await db.execute('delete from dcache');
  }

  @override
  clearExpired() async {
    final db = await this._database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.execute('delete from dcache where ?>=expired', [now]);
  }

  Map<String, dynamic> _buildHeaderMap(HttpHeaders header) {
    final map = Map<String, dynamic>();
    header.forEach((key, values) {
      map[key] = values;
    });
    return map;
  }

  @override
  Future<Response> getResponse({String key}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final db = await this._database;
    final result = await db
        .rawQuery('select * from dcache where key=? and ?<expired', [key, now]);
    if (result.length > 0) {
      final first = result.first;
      dynamic data = first['data'];
      data = this.encoder == null ? data : this.encoder.decode(data);
      String headerStr = first['header'] as String;
      headerStr = this.encoder == null ? headerStr : this.encoder.decode(headerStr);
      final headers = DioHttpHeaders.fromMap(jsonDecode(headerStr));
      final code = first['code'] as int;
      final msg = first['message'] as String;
      String extraStr = first['extra'] as String;
      extraStr = this.encoder == null ? extraStr : this.encoder.decode(extraStr);
      final extra = jsonDecode(extraStr) as Map<String, dynamic>;
      extra['fromCache'] = true;
      final responseType = first['responseType'] as int;
      if (responseType == ResponseType.json.index) {
        data = jsonDecode(data);
      }
      final resp = Response(
        data: data,
        headers: headers,
        statusCode: code,
        statusMessage: msg,
        extra: extra,
      );
      return resp;
    }
    return null;
  }

  @override
  Future<bool> setResponse({
    String key,
    Response response,
    Duration age,
  }) async {
    final responseType = response.request.responseType;
    if (responseType == ResponseType.stream) {
      return false;
    }
    dynamic data = response.data;
    if (data is Map) {
      data = jsonEncode(data);
    }
    data = this.encoder == null ? data : this.encoder.encode(data);
    final header = response.headers;
    final headerMap = _buildHeaderMap(header);
    String headerStr = jsonEncode(headerMap);
    headerStr = this.encoder == null ? headerStr : this.encoder.encode(headerStr);
    final url =
        response.request.method + ': ' + response.request.uri.toString();
    final extra = response.extra;
    String extraStr = jsonEncode(extra);
    extraStr = this.encoder == null ? extraStr : this.encoder.encode(extraStr);
    final db = await this._database;
    final now = DateTime.now();
    final expired = now.add(age);
    await db.execute(
      '''
    replace into dcache
    (key, url, data, responseType, header, code, message, extra, time, expired) VALUES 
    (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        key,
        url,
        data,
        response.request.responseType.index,
        headerStr,
        response.statusCode,
        response.statusMessage,
        extraStr,
        now.millisecondsSinceEpoch,
        expired.millisecondsSinceEpoch,
      ],
    );
    return true;
  }
}

