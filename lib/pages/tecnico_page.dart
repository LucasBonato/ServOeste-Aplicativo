import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:serv_oeste/components/search_field.dart';
import 'package:serv_oeste/service/tecnico_service.dart';
import '../components/dialog_box.dart';
import '../models/tecnico.dart';

const List<String> list = <String>['Ativo', 'Licença', 'Desativado'];

class TecnicoPage extends StatefulWidget {
  final VoidCallback onFabPressed;
  final Function(int) onEditPressed;

  const TecnicoPage({super.key, required this.onFabPressed, required this.onEditPressed});

  @override
  State<TecnicoPage> createState() => _TecnicoPageState();
}

class _TecnicoPageState extends State<TecnicoPage> {
  final TecnicoService tecnicoService = TecnicoService();
  final List<int> _selectedItems = [];
  List<Tecnico>? tecnicos;
  String _dropDownValue = list.first;
  bool isLoaded = false,
      isSelected = false;

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

  Future<void> findBy({int? id, String? nome, String? situacao}) async{
    if(nome != null && nome.isNotEmpty){
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
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Técnicos...",
            onChangedAction: (String nome) => findBy(nome: nome)
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) => findBy(id: int.tryParse(value)),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: "Id",
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
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: DropdownButton<String>(
                    alignment: AlignmentDirectional.center,
                    value: _dropDownValue,
                    items: list.map<DropdownMenuItem<String>>((String value) =>
                        DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        )
                    ).toList(),
                    onChanged: (valorSelecionado) {
                      setState(() {
                        _dropDownValue = valorSelecionado!;
                        findBy(situacao: _dropDownValue);
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
          const Padding(
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
          isLoaded ? Flexible(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 649,
                      child: ListView.builder(
                        shrinkWrap: true,
                        reverse: false,
                        scrollDirection: Axis.vertical,
                        itemCount: tecnicos!.length,
                        itemBuilder: (context, index) {
                          final tecnico = tecnicos![index];
                          return ListTile(
                              tileColor: (_selectedItems.contains(tecnico.id!)) ? Colors.blue.withOpacity(.5) : Colors.transparent,
                              leading: Text("${tecnico.id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              title: Text("${tecnico.nome} ${tecnico.sobrenome}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Telefone: ${(verifyTelefone(tecnico))}"),
                              trailing: (isSelected && _selectedItems.length == 1 && _selectedItems.contains(tecnico.id)) ?
                              IconButton(
                                onPressed: () => widget.onEditPressed(tecnico.id!),
                                icon: const Icon(Icons.edit, color: Colors.white,),
                                style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue)
                                ),
                              ) :
                              Text("${tecnico.situacao}"),
                              onLongPress: () => selectItens(tecnico.id!),
                              onTap: () {
                                setState(() {
                                  if (_selectedItems.isNotEmpty) {
                                    removeItens(tecnico.id!);
                                  }
                                  if (_selectedItems.isEmpty) {
                                    isSelected = false;
                                  }
                                });
                              }
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )  : const Flexible(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 320),
                child: CircularProgressIndicator(),
              )
            ),
          ),
        ]
      )
    );
  }
}
