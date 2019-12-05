import 'dart:convert';

/// The default encoder does nothing.
/// Usually, the response header, data, extra will be encoded.
/// T may be List<int> or String.
class DCacheEncoder {
  const DCacheEncoder();
  T encode<T>(T data) => data;

  T decode<T>(T data) => data;
}


/// DBase64Encoder provide base64 encoder for Response.data.
class DBase64Encoder extends DCacheEncoder {
  @override
  T encode<T>(T data) {
    if (data is String) {
      final result = base64Encode(utf8.encode(data));
      return (result as T);
    } else {
      return data;
    }
  }

  @override
  T decode<T>(T data) {
    if (data is String) {
      final result = utf8.decode(base64Decode(data));
      return result as T;
    } else {
      return data;
    }
  }
}