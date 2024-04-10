import 'dart:convert';
import 'package:serv_oeste/models/tecnico.dart';
import 'package:http/http.dart' as http;

class ServOesteApi{
  var client = http.Client();
  String baseUri = "http://10.0.2.2:8080/tecnico";

  Future<List<Tecnico>?> getAllTecnicos() async{
    var uri = Uri.parse(baseUri);
    var response = await client.get(uri);

    if(response.statusCode == 200){
      var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
      List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
      List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
      return tecnicos;
    }
    return null;
  }

  Future<List<Tecnico>?> getByNome(String nome) async{
    var uri = Uri.parse("$baseUri/nome?n=$nome");
    var response = await client.get(uri);

    if(response.statusCode == 200){
      var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
      List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
      List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
      return tecnicos;
    }
    return null;
  }
}