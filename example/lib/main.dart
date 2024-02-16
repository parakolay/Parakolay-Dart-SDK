import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:parakolay/parakolay.dart';

void main() {
  runApp(const MyApp());
}

class PKInAppBrowser extends InAppBrowser {
  //Can be another function like onLoadStart, onLoadStop, onLoadError according to your needs
  @override
  void onLoadError(url, code, message) {
    if (url.toString().contains("3d-callback")) {
      close();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parakolay Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Parakolay Example Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final PKInAppBrowser browser = PKInAppBrowser();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  String apiKey = 'YOUR_API_KEY';
  String apiSecret = 'YOUR_API_SECRET';
  String merchantNumber = 'YOUR_MERCHANT_NUMBER';
  String conversationId = 'YOUR_CONVERSATION_ID';

  String baseUrl = 'https://api.parakolay.com';
  String testUrl = 'https://api-test.parakolay.com';

  int amount = 1;
  int pointAmount = 0;

  late Parakolay apiClient;

  Future<String> init3Ds() async {
    String cardNumber = 'CARD_NUMBER';
    String cardholderName = 'CARD_HOLDER_NAME';
    String expireMonth = 'EXPIRE_MONTH (MM)';
    String expireYear = 'EXPIRE_YEAR (YY)';
    String cvc = 'CVC';
    String callbackURL =
        'http://localhost:8080/3d-callback'; //Should be changed with your callback URL

    return await apiClient.init3DS(
        cardNumber,
        cardholderName,
        expireMonth.toString(),
        expireYear.toString(),
        cvc,
        amount,
        pointAmount,
        callbackURL);
  }

  @override
  Widget build(BuildContext context) {
    apiClient =
        Parakolay(baseUrl, apiKey, apiSecret, merchantNumber, conversationId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
                elevation: 0,
              ),
              onPressed: () async {
                var result = await init3Ds();

                widget.browser.openData(data: result);
              },
              child: const Text("Start 3DS"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(
                  color: Colors.green,
                ),
                elevation: 0,
              ),
              onPressed: () async {
                var result = await apiClient.complete3DS();
                print(result); //Result of the payment process.
              },
              child: const Text("Complete 3DS"),
            ),
          ],
        ),
      ),
    );
  }
}
