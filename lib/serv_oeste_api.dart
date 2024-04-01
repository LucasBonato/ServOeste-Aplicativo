
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serv_oeste/models/tecnico.dart';

class CountryApi {
  Future<List<Tecnico>?> getAllCountries() async {
    var client = http.Client();
    var uri = Uri.parse('http://10.0.2.2:8080/tecnico');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return tecnicoFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }
}