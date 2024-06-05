import 'package:flutter/material.dart';
import 'package:serv_oeste/components/search_field.dart';
import 'package:serv_oeste/service/tecnico_service.dart';
import '../../components/dialog_box.dart';
import '../../models/tecnico.dart';

List<String> list = <String>['Ativo', 'Licença', 'Desativado'];

class TecnicoPage extends StatefulWidget {
  final VoidCallback onFabPressed;
  final Function(int) onEditPressed;

  const TecnicoPage({super.key, required this.onFabPressed, required this.onEditPressed});

  @override
  State<TecnicoPage> createState() => _TecnicoPageState();
}

class _TecnicoPageState extends State<TecnicoPage> {
  final TecnicoService tecnicoService = TecnicoService();
  final List<int> _selectedItens = [];
  late List<Tecnico>? tecnicos;
  final TextEditingController _idController = TextEditingController(),
      _nomeController = TextEditingController(),
      _situacaoController = TextEditingController();
  String _dropDownValue = list.first;
  bool isLoaded = false,
      isSelected = false;
  int? _id;
  String? _nome,
      _situacao;

  @override
  void initState() {
    super.initState();
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
        onPressed: widget.onFabPressed,
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
            onChangedAction: (String nome) {
              _nomeController.text = nome;
              findBy(nome: nome);
            }
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _idController,
                    onChanged: (value) => findBy(id: int.tryParse(value)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F4F8),
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
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: DropdownButton<String>(
                        alignment: AlignmentDirectional.center,
                        value: _dropDownValue,
                        items: list.map<DropdownMenuItem<String>>((String value) =>
                            DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            )).toList(),
                        onChanged: (valorSelecionado) {
                          setState(() {
                            _dropDownValue = valorSelecionado!;
                          });
                          _situacaoController.text = valorSelecionado!;
                          findBy(situacao: _dropDownValue);
                        }
                    ),
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
          Flexible(
            flex: 1,
            child: isLoaded ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              scrollDirection: Axis.vertical,
              itemCount: tecnicos!.length,
              itemBuilder: (context, index) {
                final Tecnico tecnico = tecnicos![index];
                final int id = tecnico.id!;
                final String nomeCompleto = "${tecnico.nome} ${tecnico.sobrenome}",
                    telefone = transformTelefone(tecnico),
                    situacao = tecnico.situacao.toString();
                final bool editable = (isSelected && _selectedItens.length == 1 && _selectedItens.contains(id));
                return ListTile(
                    tileColor: (_selectedItens.contains(id)) ? Colors.blue.withOpacity(.5) : null,
                    leading: Text("$id", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    title: Text(nomeCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Telefone: $telefone"),
                    trailing: (editable) ? IconButton(
                      onPressed: () => widget.onEditPressed(id),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
                    ) : Text(situacao),
                    onLongPress: () => selectItens(id),
                    onTap: () {
                      if (_selectedItens.isNotEmpty) {
                        selectItens(id);
                      }
                      if (_selectedItens.isEmpty) {
                        isSelected = false;
                      }
                    }
                );
              },
            ) : const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ]
      )
    );
  }
}
