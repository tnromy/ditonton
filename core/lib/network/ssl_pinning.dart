import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// HTTP client that only trusts the certificate authority used by the TMDB
/// API (Amazon Root CA 1). Any other chain fails the TLS handshake.
class SslPinning {
  SslPinning._();

  static const certificateAsset =
      'packages/core/certificates/amazon_root_ca_1.pem';

  static Future<SecurityContext> securityContext({AssetBundle? bundle}) async {
    final certificate = await (bundle ?? rootBundle).load(certificateAsset);
    return SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(certificate.buffer.asUint8List());
  }

  static Future<http.Client> createClient({AssetBundle? bundle}) async {
    final httpClient = HttpClient(
      context: await securityContext(bundle: bundle),
    )..badCertificateCallback = rejectBadCertificate;
    return IOClient(httpClient);
  }

  static bool rejectBadCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) => false;
}
