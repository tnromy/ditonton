import 'dart:io';

import 'package:core/network/ssl_pinning.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';

class _FileAssetBundle extends CachingAssetBundle {
  _FileAssetBundle(this.requested);

  final List<String> requested;

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    final bytes = File('certificates/amazon_root_ca_1.pem').readAsBytesSync();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

class _FakeCertificate implements X509Certificate {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('should load the pinned certificate from the core package', () async {
    final requested = <String>[];
    final context = await SslPinning.securityContext(
      bundle: _FileAssetBundle(requested),
    );

    expect(context, isA<SecurityContext>());
    expect(requested, [SslPinning.certificateAsset]);
    expect(
      SslPinning.certificateAsset,
      'packages/core/certificates/amazon_root_ca_1.pem',
    );
  });

  test('should create an IOClient that uses the pinned context', () async {
    final client = await SslPinning.createClient(bundle: _FileAssetBundle([]));

    expect(client, isA<IOClient>());
    client.close();
  });

  test('should never accept a certificate outside the pinned chain', () {
    final cert = _FakeCertificate();
    expect(SslPinning.rejectBadCertificate(cert, 'evil.example', 443), isFalse);
  });

  test('should bundle a valid PEM certificate', () {
    final pem = File('certificates/amazon_root_ca_1.pem').readAsStringSync();
    expect(pem, startsWith('-----BEGIN CERTIFICATE-----'));
  });
}
