import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/screens/cliente/update_cliente.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';
import 'package:serv_oeste/src/components/expandable_fab.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import '../../components/search_field.dart';
import 'package:flutter/material.dart';
import '../../models/cliente/cliente.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _Clientescreenstate();
}

class _Clientescreenstate extends State<ClientePage> {
  //final ClienteService clienteService = ClienteService();
  final List<int> _selectedItens = [];
  late TextEditingController _nomeController, _telefoneController, _enderecoController;
  bool isLoaded = false,
      isSelected = false;
  String? _nome, _telefone, _endereco;
  late final ClienteBloc _clienteBloc;

  @override
  void initState() {
    super.initState();
    _clienteBloc = ClienteBloc();
    _clienteBloc.add(ClienteLoadingEvent());

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
    _clienteBloc.close();
    super.dispose();
  }

  void carregarClientes() async {
    /*
    clientes = await clienteService.getAllCliente(
        _nome,
        _telefone,
        _endereco
    );
    */
    setState(() {
      isLoaded = true;
      isSelected = false;
      _selectedItens.clear();
    });
  }

  void deletarClientes() async {
    //await clienteService.disableList(_selectedItens);
    carregarClientes();
  }

  void findBy({String? nome, String? telefone, String? endereco}) {
    if (nome != null && nome.isNotEmpty) _nome = nome;
    if (telefone != null && telefone.isNotEmpty) _telefone = telefone;
    if (endereco != null && endereco.isNotEmpty) _endereco = endereco;

    if (_nomeController.text.isEmpty) _nome = null;
    if (_telefoneController.text.isEmpty) _telefone = null;
    if (_enderecoController.text.isEmpty) _endereco = null;

    carregarClientes();
  }

  void selectItens(int id) {
    if (_selectedItens.contains(id)) {
      setState(() {
        _selectedItens.removeWhere((value) => value == id);
      });
      return;
    }
    _selectedItens.add(id);
    setState(() {
      if (!isSelected) isSelected = true;
    });
  }

  ExpandableFab _buildFab(BuildContext context) {
    return ExpandableFab(
        distance: 100,
        children: [
          Column(
            children: [
              FloatingActionButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed("/createCliente"),
                heroTag: "cliente",
                mini: true,
                shape: const CircleBorder(eccentricity: 0),
                child: const Icon(Icons.person_add_alt_1),
              ),
              const Text("Cliente")
            ],
          ),
          Column(
            children: [
              FloatingActionButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed("/createServico"),
                  heroTag: "servico",
                  mini: true,
                  shape: const CircleBorder(eccentricity: 0),
                  child: const Icon(Icons.content_paste)
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
      floatingActionButton: (!isSelected) ? _buildFab(context) : BuildWidgets.buildFabRemove(context, deletarClientes),
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
            child: BlocBuilder<ClienteBloc, ClienteState>(
              bloc: _clienteBloc,
              builder: (context, state) {
                return switch(state) {
                  ClienteInitialState() ||
                  ClienteLoadingState() => const Center(child: CircularProgressIndicator.adaptive()),

                  ClienteSuccessState() => SuperListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        scrollDirection: Axis.vertical,
                        itemCount: state.clientes.length,
                        itemBuilder: (context, index) {
                          final Cliente cliente = state.clientes[index];
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
                      ),

                  ClienteErrorState() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.not_interested, size: 30),
                      const SizedBox(height: 16),
                      Text(state.error.error)
                    ],
                  ),
                };
              },
            )
          )
        ]
      )
    );
  }
}