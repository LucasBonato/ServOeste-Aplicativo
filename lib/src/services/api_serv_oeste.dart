import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../src/models/endereco.dart';

class ServOesteApi{
  var client = http.Client();

  Future<String?> getEndereco(String cep) async{
    var uri = Uri.parse("$baseUri/endereco?cep=$cep");
    var response = await client.get(uri);


    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    dynamic jsonResponse = json.decode(responseBodyUtf8);
    Endereco? endereco = Endereco.fromJson(jsonResponse);
    return endereco.endereco;
  }

}