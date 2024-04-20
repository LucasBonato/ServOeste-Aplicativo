import 'package:flutter/material.dart';
import 'package:serv_oeste/components/search_field.dart';
import 'package:serv_oeste/service/tecnico_service.dart';
import '../components/dialog_box.dart';
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
  bool isLoaded = false,
      isSelected = false;
  final List<int> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    carregarTecnicos();
  }

  Future<void> carregarTecnicos() async {
    tecnicos = await tecnicoService.getAllTecnico();
    setState(() {
      isLoaded = true;
      isSelected = false;
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

  void selectItens(int id) {
    if(!_selectedItems.contains(id)){
      setState(() {
        _selectedItems.add(id);
        if(!isSelected){
          isSelected = true;
        }
      });
    }
  }

  void removeItens(int id) {
    if(_selectedItems.contains(id)){
      _selectedItems.removeWhere((value) => value == id);
      return;
    }
    selectItens(id);
    return;
  }

  void desativarTecnicos() async{
    await tecnicoService.disableList(_selectedItems);
    carregarTecnicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: (!isSelected) ? null : Colors.red,
        shape: const CircleBorder(eccentricity: 0),
        onPressed: (!isSelected) ? widget.onFabPressed : () =>  DialogUtils.showConfirmationDialog(context, "Desativar Técnicos selecionados?", "", "Sim", "Não", desativarTecnicos),
        child: (!isSelected) ? const Icon(Icons.add) : const Icon(Icons.remove, color: Colors.white,),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchTextField(hint: "Procure por Técnicos...", onChangedAction: (String nome) => findByName(nome)),
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
                          tileColor: (_selectedItems.contains(tecnicos![index].id!)) ? Colors.blue.withOpacity(.5) : Colors.transparent,
                          leading:Text("${tecnicos?[index].id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          title: Text("${tecnicos?[index].nome} ${tecnicos?[index].sobrenome}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Telefone: ${(verifyTelefone(tecnicos?[index]))}"),
                          trailing: Text("${tecnicos?[index].situacao}"),
                          onLongPress: () => selectItens(tecnicos![index].id!),
                          onTap: () {
                            setState(() {
                              if(_selectedItems.isNotEmpty){
                                removeItens(tecnicos![index].id!);
                              }
                              if(_selectedItems.isEmpty){
                                isSelected = false;
                              }
                            });
                          },
                        ),
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                    ),
                  )]
                )
              ]
            ) : const Flexible(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 320),
                  child: CircularProgressIndicator(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
