import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PhotoCryptoService {
  PhotoCryptoService._();
  static final PhotoCryptoService _instance = PhotoCryptoService._();
  factory PhotoCryptoService() => _instance;

  static const _kDataKey = 'photo_crypto_master_key_v1';
  final _secureStorage = const FlutterSecureStorage();
  final _algo = AesGcm.with256bits();

  Future<String> encryptFileAtRest(String inputPath) async {
    final plainFile = File(inputPath);
    if (!await plainFile.exists()) {
      throw Exception('Foto sumber tidak ditemukan');
    }

    final plainBytes = await plainFile.readAsBytes();
    final secretKey = await _loadOrCreateKey();
    final nonce = _algo.newNonce();

    final secretBox = await _algo.encrypt(
      plainBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final payload = _EncryptedPayload(
      v: 1,
      nonce: base64Encode(secretBox.nonce),
      cipher: base64Encode(secretBox.cipherText),
      mac: base64Encode(secretBox.mac.bytes),
    );

    final encPath = '$inputPath.enc';
    final encFile = File(encPath);
    await encFile.writeAsString(jsonEncode(payload.toJson()));

    // Hapus plaintext setelah enkripsi sukses
    if (await plainFile.exists()) {
      await plainFile.delete();
    }

    return encPath;
  }

  Future<Uint8List> decryptFileToBytes(String encryptedPath) async {
    final file = File(encryptedPath);
    if (!await file.exists()) {
      throw Exception('File terenkripsi tidak ditemukan');
    }

    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final payload = _EncryptedPayload.fromJson(map);
    if (payload.v != 1) {
      throw Exception('Versi enkripsi tidak didukung');
    }

    final secretKey = await _loadOrCreateKey();
    final box = SecretBox(
      base64Decode(payload.cipher),
      nonce: base64Decode(payload.nonce),
      mac: Mac(base64Decode(payload.mac)),
    );

    final plain = await _algo.decrypt(
      box,
      secretKey: secretKey,
    );

    return Uint8List.fromList(plain);
  }

  Future<SecretKey> _loadOrCreateKey() async {
    final existing = await _secureStorage.read(key: _kDataKey);
    if (existing != null && existing.isNotEmpty) {
      return SecretKey(base64Decode(existing));
    }

    final generated = await _algo.newSecretKey();
    final bytes = await generated.extractBytes();
    await _secureStorage.write(
      key: _kDataKey,
      value: base64Encode(bytes),
    );
    return SecretKey(bytes);
  }
}

class _EncryptedPayload {
  final int v;
  final String nonce;
  final String cipher;
  final String mac;

  const _EncryptedPayload({
    required this.v,
    required this.nonce,
    required this.cipher,
    required this.mac,
  });

  Map<String, dynamic> toJson() {
    return {
      'v': v,
      'nonce': nonce,
      'cipher': cipher,
      'mac': mac,
    };
  }

  factory _EncryptedPayload.fromJson(Map<String, dynamic> map) {
    return _EncryptedPayload(
      v: (map['v'] as num?)?.toInt() ?? 1,
      nonce: map['nonce']?.toString() ?? '',
      cipher: map['cipher']?.toString() ?? '',
      mac: map['mac']?.toString() ?? '',
    );
  }
}

