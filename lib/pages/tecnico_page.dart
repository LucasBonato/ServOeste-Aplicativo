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

  Future<void> findByName(String nome) async{
    if(nome.isNotEmpty){
      isLoaded = false;
      tecnicos = await tecnicoService.getByNome(nome);
      setState(() {
        isLoaded = true;
      });
      return;
    }
    carregarTecnicos();
  }

  String? verifyTelefone(Tecnico? tecnico){
    var telefone = tecnico?.telefoneCelular;
    return (telefone != null) ? formatTelefone(telefone) : formatTelefone(tecnico!.telefoneFixo);
  }

  String formatTelefone(String? telefone){
    List<String> caracteresTelefone = telefone!.split("");
    String telefoneFormatado = "(";
    for(int i = 0; i < caracteresTelefone.length; i++){
      if(i == 2){telefoneFormatado += ") ";}
      if(i == 7){telefoneFormatado += "-";}
      telefoneFormatado += caracteresTelefone[i];
    }
    return telefoneFormatado;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
            child: TextFormField(
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: Color(0xFF57636C),
                ),
                isDense: false,
                labelText: 'Procure por Técnicos...',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFF1F4F8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F4F8),
              ),
              onChanged: (value) => setState(() {findByName(value);}),
            ),
          ),
          isLoaded ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text("Id", textAlign: TextAlign.start, style: TextStyle(fontSize: 20))),
                        Expanded(flex: 3, child: Text("Nome", textAlign: TextAlign.start, style: TextStyle(fontSize: 20))),
                        Expanded(flex: 2, child: Text("Situação", textAlign: TextAlign.end, style: TextStyle(fontSize: 20))),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: tecnicos!.length,
                    itemBuilder: (context, index) => ListTile(
                      leading:Text("${tecnicos?[index].id}", style: const TextStyle(fontSize: 20)),
                      title: Text("${tecnicos?[index].nome} ${tecnicos?[index].sobrenome}"),
                      subtitle: Text("Telefone: ${(verifyTelefone(tecnicos?[index]))}"),
                      trailing: Text("${tecnicos?[index].situacao}"),
                    ),
                  ),
                )
              )
            ]) : const Flexible(child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

