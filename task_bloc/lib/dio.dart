import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: "https://jsonplaceholder.typicode.com",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {"Accept": "application/json"},
  ),
);
