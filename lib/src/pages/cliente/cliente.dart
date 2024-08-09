import 'package:serv_oeste/src/pages/cliente/create_cliente.dart';
import 'package:serv_oeste/src/pages/cliente/update_cliente.dart';
import 'package:serv_oeste/src/services/cliente_service.dart';
import 'package:serv_oeste/src/util/constants.dart';
import 'package:serv_oeste/src/widgets/expandable_fab.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import '../../widgets/search_field.dart';
import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../servico/create_servico.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteService clienteService = ClienteService();
  final List<int> _selectedItens = [];
  late List<Cliente>? clientes;
  late TextEditingController _nomeController, _telefoneController, _enderecoController;
  bool isLoaded = false, isSelected = false;
  String? _nome, _telefone, _endereco;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    carregarClientes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void carregarClientes() async{
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

  void deletarClientes() async{
    await clienteService.disableList(_selectedItens);
    carregarClientes();
  }

  void findBy({String? nome, String? telefone, String? endereco}) {
    if(nome != null && nome.isNotEmpty) _nome = nome;
    if(telefone != null && telefone.isNotEmpty) _telefone = telefone;
    if(endereco != null && endereco.isNotEmpty) _endereco = endereco;

    if (_nomeController.text.isEmpty) _nome = null;
    if (_telefoneController.text.isEmpty) _telefone = null;
    if (_enderecoController.text.isEmpty) _endereco = null;

    carregarClientes();
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

  ExpandableFab _buildFab(BuildContext context) {
    return ExpandableFab(
      distance: 100,
      children: [
        Column(
          children: [
            ActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCliente())),
              icon: const Icon(Icons.person_add_alt_1)
            ),
            const Text("Cliente")
          ],
        ),
        Column(
          children: [
            ActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateServico())),
              icon: const Icon(Icons.content_paste)
            ),
            const Text("Serviço")
          ],
        )
      ]
    );
  }

  Widget _buildEditableSection(int id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              isSelected = false;
              _selectedItens.clear();
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateCliente(id: id))
            );
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
        ),
        const SizedBox(
          width: 16,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isSelected = false;
              _selectedItens.clear();
            });

          },
          icon: const Icon(Icons.content_paste, color: Colors.white),
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected) ? _buildFab(context) : Constants.buildFabRemove(context, deletarClientes),
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Clientes...",
            controller: _nomeController,
            onChangedAction: (String nome) => findBy(nome: nome)
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SearchTextField(
                  hint: "Telefone...",
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  rightPadding: 0,
                  onChangedAction: (String telefone) => findBy(telefone: telefone)
                ),
              ),
              Expanded(
                flex: 5,
                child: SearchTextField(
                  hint: "Endereço...",
                  controller: _enderecoController,
                  leftPadding: 8,
                  onChangedAction: (String endereco) => findBy(endereco: endereco)
                ),
              )
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
                    Expanded(flex: 2, child: Text("Município", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: isLoaded ? SuperListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              scrollDirection: Axis.vertical,
              itemCount: clientes!.length,
              itemBuilder: (context, index) {
                final Cliente cliente = clientes![index];
                final int id = cliente.id!;
                final bool editable = (isSelected && _selectedItens.length == 1 && _selectedItens.contains(id));
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: ListTile(
                    leading: Text("$id", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    title: Text(cliente.nome!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(Constants.transformTelefone(cliente: cliente)),
                    trailing: (editable) ? _buildEditableSection(id) : Text(cliente.municipio != null ? cliente.municipio! : "UF"),
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