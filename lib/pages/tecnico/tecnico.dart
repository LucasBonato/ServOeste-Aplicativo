import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/pages/tecnico/create_tecnico.dart';
import 'package:serv_oeste/pages/tecnico/update_tecnico.dart';
import 'package:serv_oeste/widgets/search_field.dart';
import 'package:serv_oeste/api/service/tecnico_service.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import '../../widgets/dialog_box.dart';
import '../../models/tecnico.dart';

List<String> list = <String>['Ativo', 'Licença', 'Desativado'];

class TecnicoPage extends StatefulWidget {
  const TecnicoPage({super.key});

  @override
  State<TecnicoPage> createState() => _TecnicoPageState();
}

class _TecnicoPageState extends State<TecnicoPage> {
  final TecnicoService tecnicoService = TecnicoService();
  final List<int> _selectedItens = [];
  late List<Tecnico>? tecnicos;
  late TextEditingController _idController, _nomeController, _situacaoController;
  bool isLoaded = false, isSelected = false, isDropDown = false;
  int? _id;
  String? _nome, _situacao;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = TextEditingController();
    carregarTecnicos();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _situacaoController.dispose();
    super.dispose();
  }

  Future<void> carregarTecnicos({String? situacao = "ativo"}) async {
    tecnicos = await tecnicoService.getByIdNomesituacao(_id, _nome, situacao);
    setState(() {
      isLoaded = true;
      isSelected = false;
      _selectedItens.clear();
    });
    return;
  }

  void desativarTecnicos() async{
    await tecnicoService.disableList(_selectedItens);
    carregarTecnicos();
  }

  void findBy({int? id, String? nome, String? situacao}) {
    if(id != null) _id = id;
    if(nome != null && nome.isNotEmpty) _nome = nome;
    if(situacao != null) _situacao = situacao.toLowerCase();

    if (_idController.text.isEmpty) _id = null;
    if (_nomeController.text.isEmpty) _nome = null;
    if (_situacaoController.text.isEmpty) _situacao = null;

    carregarTecnicos(situacao: _situacao);
  }

  void selectItens(int id) {
    if(_selectedItens.contains(id)){
      setState(() {
        _selectedItens.removeWhere((value) => value == id);
      });
      return;
    }
    _selectedItens.add(id);
    setState(() {
      if(!isSelected) isSelected = true;
    });
  }

  String transformTelefone(Tecnico? tecnico){
    var telefoneC = tecnico?.telefoneCelular ?? "";
    var telefoneF = tecnico?.telefoneFixo ?? "";
    String telefone = (telefoneC.isNotEmpty) ? telefoneC : telefoneF;
    String telefoneFormatado = "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
    return telefoneFormatado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected) ? FloatingActionButton(
        backgroundColor: null,
        shape: const CircleBorder(eccentricity: 0),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTecnico())),
        child: const Icon(Icons.add),
      ) : FloatingActionButton(
        backgroundColor: Colors.red,
        shape: const CircleBorder(eccentricity: 0),
        onPressed: () =>  DialogUtils.showConfirmationDialog(context, "Desativar Técnicos selecionados?", "", "Sim", "Não", desativarTecnicos),
        child: const Icon(Icons.remove, color: Colors.white),
      ),
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Técnicos...",
            controller: _nomeController,
            onChangedAction: (String nome) => findBy(nome: nome)
          ), // Nome Técnicos
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SearchTextField(
                  hint: 'Id',
                  keyboardType: TextInputType.number,
                  controller: _idController,
                  onChangedAction: (value) => findBy(id: int.tryParse(value))
                ),
              ), // Id Técnicos
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 16, 0),
                  child: DropDownSearchField(
                    hideKeyboard: true,
                    displayAllSuggestionWhenTap: true,
                    suggestionsCallback: (String pattern) => list,
                    itemBuilder: (BuildContext context, String suggestion) {
                      return ListTile(
                        title: Text(suggestion)
                      );
                    },
                    onSuggestionSelected: (String suggestion) {
                      _situacaoController.text = suggestion;
                      findBy(situacao: _situacaoController.text);
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _situacaoController,
                      keyboardType: TextInputType.none,
                      decoration: InputDecoration(
                        label: const Text("Situação"),
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Color(0xFF57636C),
                        ),
                        isDense: false,
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
              ), // Situação Técnicos
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(21, 72, 169, 1)
              ),
              child: const SizedBox(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text("Id", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text("Nome", textAlign: TextAlign.start, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Situação", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: isLoaded ? SuperListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              scrollDirection: Axis.vertical,
              itemCount: tecnicos!.length,
              itemBuilder: (context, index) {
                final Tecnico tecnico = tecnicos![index];
                final int id = tecnico.id!;
                final bool editable = (isSelected && _selectedItens.length == 1 && _selectedItens.contains(id));
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: ListTile(
                    leading: Text("$id", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    title: Text("${tecnico.nome} ${tecnico.sobrenome}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text("Telefone: ${transformTelefone(tecnico)}"),
                    trailing: (editable) ? IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTecnico(id: id))),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
                    ) : Text(tecnico.situacao.toString()),
                    onLongPress: () => selectItens(id),
                    onTap: () {
                      if (_selectedItens.isNotEmpty) {
                        selectItens(id);
                      }
                      if (_selectedItens.isEmpty) {
                        isSelected = false;
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    tileColor: const Color.fromRGBO(239, 239, 239, 100),
                    selectedTileColor: Colors.blue.withOpacity(.5),
                    selected: _selectedItens.contains(id),
                  ),
                );
              },
            ) : const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ]
      )
    );
  }
}