library parakolay;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parakolay/utils/helpers.dart';

class Parakolay {
  String version = "v1.0";

  http.Client multipartClient = http.Client();
  http.Client jsonClient = http.Client();

  String apiKey;
  String merchantNumber;
  String conversationId;

  late String nonce;
  late String signature;

  late double amount;
  late String currency;
  late String cardholderName;
  late String cardToken;
  late String threeDSessionID;

  String baseUrl;
  late Map<String, String> headers;
  late Map<String, String> headers3dSession;

  Parakolay(this.baseUrl, this.apiKey, String apiSecret, this.merchantNumber,
      this.conversationId) {
    nonce = getMilliseconds();
    signature = generateSignature(apiKey, apiSecret, nonce, conversationId);

    headers = {
      'User-Agent': 'Parakolay Dart SDK $version',
    };

    headers3dSession = headers;
    headers3dSession.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      'publicKey': apiKey,
      'nonce': nonce,
      'signature': signature,
      'conversationId': conversationId,
      'clientIpAddress': '192.1.1.0', // IP address of the client
      'merchantNumber': merchantNumber,
    });
  }

  Future<String> init3DS(
      String cardNumber,
      String cardholderName,
      String expireMonth,
      String expireYear,
      String cvc,
      double amount,
      double pointAmout,
      String callbackURL,
      {String currency = "TRY",
      String languageCode = "TR"}) async {
    cardToken = await _getCardToken(
        cardNumber, cardholderName, expireMonth, expireYear, cvc);
    threeDSessionID =
        await _get3DSession(amount, pointAmout, currency, languageCode);
    String threedDinitResult = await _get3DInit(callbackURL, languageCode);

    return threedDinitResult;
  }

  Future<String> getPoints(
    String cardNumber,
    String cardholderName,
    String expireMonth,
    String expireYear,
    String cvc,
  ) async {
    cardToken = await _getCardToken(
        cardNumber, cardholderName, expireMonth, expireYear, cvc);
    var pointsResult = await _pointInquiry(cardToken);

    return pointsResult;
  }

  Future<String> complete3DS() async {
    String result = await _get3DSessionResult();
    if (result == "VerificationFinished") {
      var provisionResult = await _provision();
      return provisionResult;
    } else {
      return "Error";
    }
  }

  Future<String> _getCardToken(String cardNumber, String cardholderName,
      String expireMonth, String expireYear, String cvc) async {
    this.cardholderName = cardholderName;

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/Tokens'));

    request.fields.addAll({
      'CardNumber': cardNumber,
      'ExpireMonth': expireMonth,
      'ExpireYear': expireYear,
      'Cvv': cvc,
      'PublicKey': apiKey,
      'Nonce': nonce,
      'Signature': signature,
      'ConversationId': conversationId,
      'MerchantNumber': merchantNumber,
      'CardHolderName': cardholderName,
    });

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse['cardToken'];
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _get3DSession(double amount, double pointAmount,
      String currency, String languageCode) async {
    this.amount = amount;
    this.currency = currency;

    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/threeds/getthreedsession'));

    request.body = json.encode({
      'amount': amount,
      'pointAmount': pointAmount,
      'cardToken': cardToken,
      'currency': currency,
      'paymentType': "Auth",
      'installmentCount': 1,
      'languageCode': languageCode
    });

    request.headers.addAll(headers3dSession);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse['threeDSessionId'];
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _get3DInit(String callbackURL, String languageCode) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/threeds/init3ds'));

    request.fields.addAll({
      'ThreeDSessionId': threeDSessionID,
      'CallbackUrl': callbackURL,
      'LanguageCode': languageCode,
      'ClientIpAddress': '127.0.0.1', // Replace with actual IP address
      'PublicKey': apiKey,
      'Nonce': nonce,
      'Signature': signature,
      'ConversationId': conversationId,
      'MerchantNumber': merchantNumber
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse['htmlContent'];
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _get3DSessionResult({String languageCode = "TR"}) async {
    var request = http.Request(
        'POST', Uri.parse('$baseUrl/v1/threeds/getthreedsessionresult'));

    request.headers.addAll(headers3dSession);

    request.body = json.encode(
        {'threeDSessionId': threeDSessionID, 'languageCode': languageCode});

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse['currentStep'];
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _provision() async {
    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/Payments/provision'));
    request.headers.addAll(headers3dSession);

    request.body = json.encode({
      'amount': amount,
      'cardToken': cardToken,
      'currency': currency,
      'paymentType': 'Auth',
      'cardHolderName': cardholderName,
      'threeDSessionId': threeDSessionID,
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> reverse(String orderID, {String languageCode = "TR"}) async {
    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/Payments/reverse'));
    request.headers.addAll(headers3dSession);

    request.body =
        json.encode({'orderid': orderID, 'languageCode': languageCode});

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> returnAmount(double amount, String orderID,
      {String languageCode = "TR"}) async {
    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/Payments/return'));
    request.headers.addAll(headers3dSession);

    request.body = json.encode(
        {'orderid': orderID, 'amount': amount, 'languageCode': languageCode});

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> binInfo(String binNumber, {String languageCode = "TR"}) async {
    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/Payments/bin-information'));
    request.headers.addAll(headers3dSession);

    request.body =
        json.encode({'binNumber': binNumber, 'languageCode': languageCode});

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> installment(
      String binNumber, String merchantNumber, double amount) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            '$baseUrl/v1/Installment?binNumber=$binNumber&amount=$amount&merchantNumber=$merchantNumber'));
    request.headers.addAll(headers3dSession);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _pointInquiry(String cardToken,
      {String languageCode = "TR", String currency = "TRY"}) async {
    var request =
        http.Request('POST', Uri.parse('$baseUrl/v1/Payments/pointInquiry'));
    request.headers.addAll(headers3dSession);

    request.body = json.encode({
      'cardToken': cardToken,
      'languageCode': languageCode,
      'currency': currency
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(await response.stream.bytesToString());
        if (checkError(decodedResponse)) {
          return decodedResponse.toString();
        } else {
          return 'Error: ${decodedResponse['errorMessage']}';
        }
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  bool checkError(Map<String, dynamic> data) {
    if (data['isSucceed'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
