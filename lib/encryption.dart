import 'dart:convert';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';

void main() {
  String plaintext = 'This is a secret message';
  String key = '0123456789abcdef0123456789abcdef'; // 256-bit key
  String iv = '0123456789abcdef'; // 128-bit IV
  var hex;
  // Convert plaintext, key, and IV to bytes
  List<int> plaintextBytes = utf8.encode(plaintext);

  List<int> keyBytes = hex.decode(key);
  List<int> ivBytes = hex.decode(iv);

  // Perform AES encryption and measure time taken
  Stopwatch stopwatch = Stopwatch()..start();
  List<int> ciphertextBytes = _aesCbcEncrypt(plaintextBytes, keyBytes, ivBytes);
  stopwatch.stop();
  int timeTaken = stopwatch.elapsedMilliseconds;

  // Print ciphertext and time taken
  print('Plaintext: $plaintext');
  print('Ciphertext: ${hex.encode(ciphertextBytes)}');
  print('Time taken (ms): $timeTaken');
}

List<int> _aesCbcEncrypt(List<int> plaintext, List<int> key, List<int> iv) {
  var AESMode;
  final encrypter = AES(Key(key as String), mode: AESMode.cbc);
  final encrypted = encrypter.encryptBytes(plaintext, iv: IV(iv));
  return encrypted.bytes;
}

class IV {
  IV(List<int> iv);
}

AES(Key key, {required mode}) {}
