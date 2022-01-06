import 'package:dio/dio.dart';

late String url;
late String logo;
late Dio dio;

enum LoginType { code, password, link }

enum AuthType { login, signup }
