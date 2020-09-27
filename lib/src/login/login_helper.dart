import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class LoginHelper {
  final String schema;
  final String host;
  final String symbol;
  String firstStepReturnUrl;

  LoginHelper(this.schema, this.host, this.symbol) {
    final url = encode(schema + '://uonetplus.' + host + '/' + symbol + '/LoginEndpoint.aspx');
    firstStepReturnUrl = '/' + symbol + '/FS/LS?wa=wsignin1.0&wtrealm=' + url + '&wctx=' + url;
  }

  Future<List<Element>> login(String name, String password) async {
    var cert = await sendCredentials(name, password);
    var home = await sendCertificate(cert);

    return home.querySelectorAll('.klient a[href*=\"uonetplus-uczen\"]');
  }

  Future<Document> sendCredentials(String name, String password) {
    var loginName = name.split('||')[0];

    return sendStandard(loginName, password);
  }

  Future<Document> sendStandard(String name, String password) async {
    final baseUrl = schema + '://cufs.' + host;
    final url = baseUrl + '/' + symbol + '/Account/LogOn?ReturnUrl=' + encode(firstStepReturnUrl);
    final response = await http.post(url, body: {
      'LoginName': name,
      'Password': password,
    });

    final secondResponse = await http.get(baseUrl + response.headers['location']);

    if (secondResponse.statusCode == 302) throw Exception('Login request not properly redirected!');

    return parse(secondResponse.body);
  }

  Future<Document> sendCertificate(Document cert) async {
    final res = await http.post(cert.querySelector('form[name=hiddenform]').attributes['action'], body: {
      'wa': cert.querySelector('input[name=wa]').attributes['value'],
      'wresult': cert.querySelector('input[name=wresult]').attributes['value'],
      'wctx': cert.querySelector('input[name=wctx]').attributes['value']
    });

    final secondResponse = await http.get(res.request.url.scheme + '://' + res.request.url.host + res.headers['location']);

    if (secondResponse.statusCode == 302) throw Exception('Certificate request not properly redirected!');

    return parse(secondResponse.body);
  }

  String encode(String url) {
    return Uri.encodeComponent(url);
  }
}
