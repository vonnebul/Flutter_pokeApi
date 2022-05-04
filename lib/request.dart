import 'dart:convert';

import "package:http/http.dart" show Client, Response;

class Request {
  final Client _request = Client();
  late String uri;
  String url;
  Request({required this.url});

  Future getFromUri(
      { required String uri, Map<String, dynamic>? params}) async {
    try {
      Response response = await _request.get(Uri.https(url, uri, params));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future getFromUrl(String url) async {
    try {
      Response response = await _request.get(Uri.parse(url));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }
}
