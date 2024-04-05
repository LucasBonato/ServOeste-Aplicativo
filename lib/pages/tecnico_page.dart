import 'package:flutter/material.dart';
import 'package:serv_oeste/service/tecnico_service.dart';

import '../models/tecnico.dart';

class TecnicoPage extends StatefulWidget {
  const TecnicoPage({super.key});

  @override
  State<TecnicoPage> createState() => _TecnicoPageState();
}

class _TecnicoPageState extends State<TecnicoPage> {
  final TecnicoService tecnicoService = TecnicoService();
  List<Tecnico>? tecnicos;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();

    carregarTecnicos();
  }

  Future<void> carregarTecnicos() async {
    tecnicos = await tecnicoService.getAllTecnico();
    setState(() {
      isLoaded = true;
    });
  }

  List<ListTile> getTecnicoTiles(){
    List<ListTile> tecnicoTiles = [];
    for(Tecnico tecnico in tecnicos!){
      tecnicoTiles.add(ListTile(
        leading: Text("${tecnico.id}"),
        title: Text("${tecnico.nome}"),
      ));
    }
    return tecnicoTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(eccentricity: 0),
        child: const Icon(Icons.add),
        onPressed: () => {},
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
          isLoaded ? Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: getTecnicoTiles(),
                ),
              ),
            ),
          ) : const Center(child: CircularProgressIndicator(),),
        ],
      ),
    );
  }
}

