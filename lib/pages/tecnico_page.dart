import 'package:flutter/material.dart';
import 'package:serv_oeste/models/ListTileTecnico.dart';
import 'package:serv_oeste/models/tecnico.dart';

class TecnicoPage extends StatefulWidget {
  const TecnicoPage({super.key});

  @override
  State<TecnicoPage> createState() => _TecnicoPageState();
}

class _TecnicoPageState extends State<TecnicoPage> {

  List tecnicoList = [1, 2, 3];

  List<ListTileTecnico> populando(){
    List<Tecnico> tecnicos = ;
    for(int i = 0; i < getLenghtTecnico().; i++){

    }
  }

  static Future<int> getLenghtTecnico() async{
    await Tecnico.getPosts().then((value) { return value.length;});
    return 0;
  }

  void addNewTecnico(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(eccentricity: 0),
        child: const Icon(Icons.add),
        onPressed: () => addNewTecnico(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
            child: TextFormField(
              obscureText: false,
              decoration: InputDecoration(
                isDense: false,
                labelText: 'Procure por Técnicos...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFF1F4F8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Color(0xFFF1F4F8),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: Color(0xFF57636C),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: tecnicoList.length,
                itemBuilder: (context, index) {
                  return ListTileTecnico(
                    id: 1,
                    nome: "Lucas",
                    sobrenome: "Bonato",
                    situacao: "ativo",
                  );
                },
              ),
          ),
        ],
      ),
    );
  }
}

