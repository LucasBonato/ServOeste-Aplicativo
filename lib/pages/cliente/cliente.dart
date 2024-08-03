import 'package:flutter/material.dart';
import 'package:serv_oeste/api/service/cliente_service.dart';
import '../../widgets/dialog_box.dart';
import '../../widgets/search_field.dart';
import '../../models/cliente.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  late List<Cliente>? clientes;
  final ClienteService clienteService = ClienteService();
  final List<int> _selectedItens = [];
  final TextEditingController _nomeController = TextEditingController(),
                              _telefoneController = TextEditingController(),
                              _enderecoController = TextEditingController();
  bool isLoaded = false,
       isSelected = false;
  String? _nome,
          _telefone,
          _endereco;

  @override
  void initState() {
    super.initState();
    carregarTecnicos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> carregarTecnicos() async{
    clientes = await clienteService.getAllCliente(
        _nome,
        _telefone,
        _endereco
    );
    setState(() {
      isLoaded = true;
      isSelected = false;
      _selectedItens.clear();
    });
  }

  Future<void> deletarClientes() async{
    await clienteService.disableList(_selectedItens);
    carregarTecnicos();
  }

  findBy({String? nome, String? telefone, String? endereco}) {
    if(nome != null && nome.isNotEmpty) _nome = nome;
    if(telefone != null && telefone.isNotEmpty) _telefone = telefone;
    if(endereco != null && endereco.isNotEmpty) _endereco = endereco;

    if (_nomeController.text.isEmpty) _nome = null;
    if (_telefoneController.text.isEmpty) _telefone = null;
    if (_enderecoController.text.isEmpty) _endereco = null;

    carregarTecnicos();
  }

  selectItens(int id) {
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

  String showTelefones(Cliente cliente) {
    var telefoneC = cliente.telefoneCelular ?? "";
    var telefoneF = cliente.telefoneFixo ?? "";
    if(telefoneF.isNotEmpty && telefoneC.isNotEmpty){
      return "Telefone Celular: ${formatTelefone(telefoneC)}\nTelefone Fixo: ${formatTelefone(telefoneF)}";
    } else if(telefoneF.isNotEmpty){
      return "Telefone Fixo: ${formatTelefone(telefoneF)}";
    }
    return "Telefone Celular: ${formatTelefone(telefoneC)}";
  }
  String formatTelefone(String telefone) {
    return "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected) ? FloatingActionButton(
        backgroundColor: null,
        shape: const CircleBorder(eccentricity: 0),
        onPressed: () => {},
        child: const Icon(Icons.add),
      ) : FloatingActionButton(
        backgroundColor: Colors.red,
        shape: const CircleBorder(eccentricity: 0),
        onPressed: () =>  DialogUtils.showConfirmationDialog(context, "Deletar Clientes selecionados?", "", "Sim", "Não", deletarClientes),
        child: const Icon(Icons.remove, color: Colors.white),
      ),
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Clientes...",
            onChangedAction: (String nome) {
              _nomeController.text = nome;
              findBy(nome: nome);
            }
          ),
          SearchTextField(
            hint: "Procure por telefone...",
            onChangedAction: (String telefone) {
              _telefoneController.text = telefone;
              findBy(telefone: telefone);
            }
          ),
          SearchTextField(
              hint: "Procure pelo endereço...",
              onChangedAction: (String endereco) {
                _enderecoController.text = endereco;
                findBy(endereco: endereco);
              }
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text("Id", textAlign: TextAlign.start, style: TextStyle(fontSize: 20))),
                  Expanded(flex: 3, child: Text("Nome", textAlign: TextAlign.start, style: TextStyle(fontSize: 20))),
                  Expanded(flex: 2, child: Text("Município", textAlign: TextAlign.end, style: TextStyle(fontSize: 20))),
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
                final String nome = cliente.nome!;
                final bool editable = (isSelected && _selectedItens.length == 1 && _selectedItens.contains(id));
                return ListTile(
                    tileColor: (_selectedItens.contains(id)) ? Colors.blue.withOpacity(.5) : null,
                    leading: Text("$id", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(showTelefones(cliente)),
                    trailing: (editable) ? IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
                    ) : Text(cliente.municipio != null ? cliente.municipio! : "UF"),
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
          const Padding(padding: EdgeInsets.only(top: 0))
        ]
      )
    );
  }
}
