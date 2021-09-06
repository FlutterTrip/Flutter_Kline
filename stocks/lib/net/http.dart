import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

BaseOptions opt = BaseOptions(
          connectTimeout: 60 * 1000,
          receiveTimeout: 1000 * 60 * 60 * 24,
          responseType: ResponseType.json,
          headers: {"Content-Type": "application/json"});
class Net {
  Dio dio = Dio(opt);
  static Net? _instance;
  Net._();
  static Net instance() {
    if (_instance == null) {
      _instance = Net._();
  }
    return _instance!;
  }

  static Future get(String url, {Map<String, String>? queryParameters, Options? options}) {
    return Net.instance().dio.get(url, queryParameters: queryParameters, options: options);
  }
}