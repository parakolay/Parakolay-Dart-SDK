import 'dart:convert';
import 'package:crypto/crypto.dart';

String getMilliseconds() {
  int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
  return millisecondsSinceEpoch.toString();
}

String generate(String message, String key) {
  var keyBytes = base64Decode(key);
  var hmacSha256 = Hmac(sha256, keyBytes);
  var digest = hmacSha256.convert(utf8.encode(message));
  return base64Encode(digest.bytes);
}

String generateSignature(
    String apiKey, String apiSecret, String nonce, String conversationId) {
  var message = apiKey + nonce;
  var securityData = generate(message, apiSecret);

  var secondMessage = apiSecret + conversationId + nonce + securityData;
  var signature = generate(secondMessage, apiSecret);

  return signature;
}
