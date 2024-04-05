import 'dart:convert';
import 'package:serv_oeste/models/tecnico.dart';
import 'package:http/http.dart' as http;

class ServOesteApi{
  Future<List<Tecnico>?> getAllTecnicos() async{
    var client = http.Client();
    var uri = Uri.parse("http://10.0.2.2:8080/tecnico");
    var response = await client.get(uri);

    if(response.statusCode == 200){
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
      return tecnicos;
      //return tecnicoFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }
}