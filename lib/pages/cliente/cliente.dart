import 'package:flutter/material.dart';
import 'package:serv_oeste/service/cliente_service.dart';
import '../../components/dialog_box.dart';
import '../../components/search_field.dart';
import '../../models/cliente.dart';

class ClientePage extends StatefulWidget {
  final VoidCallback onFabPressed;
  final Function(int) onEditPressed;

  const ClientePage({super.key, required this.onFabPressed, required this.onEditPressed});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteService clienteService = ClienteService();
  final List<int> _selectedItens = [];
  late List<Cliente>? clientes;
  final TextEditingController _idController = TextEditingController(),
      _nomeController = TextEditingController(),
      _situacaoController = TextEditingController();
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
    clientes = await clienteService.getAllCliente(_id, _nome, situacao);
    setState(() {
      isLoaded = true;
      isSelected = false;
      _selectedItens.clear();
    });
    return;
  }

  void desativarTecnicos() async{
    await clienteService.disableList(_selectedItens);
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

  String transformTelefone(Cliente? cliente){
    var telefoneC = cliente?.telefoneCelular ?? "";
    var telefoneF = cliente?.telefoneFixo ?? "";
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
                  itemCount: clientes!.length,
                  itemBuilder: (context, index) {
                    final Cliente cliente = clientes![index];
                    final int id = cliente.id!;
                    final String nomeCompleto = cliente.nome!,
                        telefone = transformTelefone(cliente);
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
                        ) : Text("Nada"),
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
