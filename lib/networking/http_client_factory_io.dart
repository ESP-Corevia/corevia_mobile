import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  final ioClient = HttpClient();

  if (kDebugMode) {
    ioClient.badCertificateCallback = (cert, host, port) {
      return host == '10.0.2.2' || host.endsWith('.corevia.local');
    };
  }

  return IOClient(ioClient);
}
