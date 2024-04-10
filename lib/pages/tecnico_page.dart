import 'package:flutter/material.dart';
import 'package:serv_oeste/service/tecnico_service.dart';
import '../models/tecnico.dart';

class TecnicoPage extends StatefulWidget {
  final VoidCallback onFabPressed;

  const TecnicoPage({super.key, required this.onFabPressed});

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
    var telefoneC = tecnico?.telefoneCelular;
    var telefoneF = tecnico?.telefoneFixo;
    List<String> caracteresTelefone = (telefoneC != "") ? telefoneC!.split("") : telefoneF!.split("");
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
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(eccentricity: 0),
        onPressed: widget.onFabPressed,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                Column(
                  children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
                    child: SizedBox(
                      height: 696,
                      child: ListView.separated(
                        shrinkWrap: true,
                        reverse: false,
                        scrollDirection: Axis.vertical,
                        itemCount: tecnicos!.length,
                        itemBuilder: (context, index) => ListTile(
                          leading:Text("${tecnicos?[index].id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          title: Text("${tecnicos?[index].nome} ${tecnicos?[index].sobrenome}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Telefone: ${(verifyTelefone(tecnicos?[index]))}"),
                          trailing: Text("${tecnicos?[index].situacao}"),
                        ),
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                    ),
                  )]
                )
              ]) : const Flexible(child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
