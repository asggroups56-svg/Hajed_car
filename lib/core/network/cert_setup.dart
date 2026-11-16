import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

Future<void> setupCert(Dio dio) async {
  final data = await rootBundle.load('assets/certs/intermediate.pem');
  final context = SecurityContext(withTrustedRoots: true)
    ..setTrustedCertificatesBytes(data.buffer.asUint8List());

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
      HttpClient(context: context);
}
