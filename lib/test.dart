import 'dart:html' as http;

import 'package:http/http.dart' as http;

void main() async {
  var url = Uri.https('https://test-payment.momo.vn', '/v2/gateway/api/create');
  var response = await http.post(url, body: {
    "partnerCode": "MOMO",
    "partnerName": "Test",
    "storeId": "MoMoTestStore",
    "requestType": "captureWallet",
    "ipnUrl": "https://momo.vn",
    "redirectUrl": "https://momo.vn",
    "orderId": "MM1540456472575",
    "amount": 150000,
    "lang": "vi",
    "orderInfo": "SDK team.",
    "requestId": "MM1540456472575",
    "extraData": "eyJ1c2VybmFtZSI6ICJtb21vIn0=",
    "signature":
        "fd37abbee777e13eaa0d0690d184e4d7e2fb43977281ab0e20701721f07a0e07"
  });
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  print(await http.read(Uri.https('example.com', 'foobar.txt')));
}
