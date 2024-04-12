import 'dart:convert';
import 'package:serv_oeste/models/tecnico.dart';
import 'package:http/http.dart' as http;

class ServOesteApi{
  var client = http.Client();
  String baseUri = "http://10.0.2.2:8080/tecnico";

  Future<List<Tecnico>?> getAllTecnicos() async{
    var uri = Uri.parse(baseUri);
    var response = await client.get(uri);

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
    List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
    return tecnicos;
  }

  Future<List<Tecnico>?> getByNome(String nome) async{
    var uri = Uri.parse("$baseUri/nome?n=$nome");
    var response = await client.get(uri);

    var responseBodyUtf8 = utf8.decode(response.body.runes.toList());
    List<dynamic> jsonResponse = json.decode(responseBodyUtf8);
    List<Tecnico> tecnicos = jsonResponse.map((json) => Tecnico.fromJson(json)).toList();
    return tecnicos;
  }
  
  Future<dynamic> postTecnico(Tecnico tecnico) async{
    var response = await client.post(
      Uri.parse(baseUri),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "nome": tecnico.nome,
        "sobrenome": tecnico.sobrenome,
        "telefoneFixo": tecnico.telefoneFixo,
        "telefoneCelular": tecnico.telefoneCelular,
        "especialidades_Ids": tecnico.especialidadesIds,
      }),
    );
    if(response.statusCode != 201){
      dynamic body = jsonDecode(utf8.decode(response.body.runes.toList()));
      return body;
    }
    return null;
  }
}