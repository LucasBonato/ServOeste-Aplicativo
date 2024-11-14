import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/screens/tecnico/create_tecnico.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class TecnicoPage extends StatefulWidget {
  const TecnicoPage({super.key});

  @override
  State<TecnicoPage> createState() => _Tecnicoscreenstate();
}

class _Tecnicoscreenstate extends State<TecnicoPage> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  late TextEditingController _idController, _nomeController, _situacaoController;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc.add(TecnicoLoadingEvent());
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = TextEditingController();
    _selectedItems = [];
  }

  void disableTecnicos() async {
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: _selectedItems));
    setState(() {
      _selectedItems.clear();
    });
  }

  void _selectItems(int id) {
    if (_selectedItems.contains(id)) {
      setState(() {
        _selectedItems.remove(id);
      });
      return;
    }
    _selectedItems.add(id);
    setState(() {
      if (!isSelected) isSelected = true;
    });
  }
  
  Widget _buildEditableSection(int id) => IconButton(
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTecnico(id: id)))
                      .then((value) => value?? _tecnicoBloc.add(TecnicoSearchEvent())),
    icon: const Icon(Icons.edit, color: Colors.white),
    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected) ? BuildWidgets.buildFabAdd(context, const CreateTecnico()) : BuildWidgets.buildFabRemove(context, disableTecnicos),
      body: Column(
        children: [
          SearchTextField(
            hint: "Procure por Técnicos...",
            controller: _nomeController,
            onChangedAction: (String nome) => _tecnicoBloc.add(
              TecnicoSearchEvent(
                nome: nome,
                id: int.parse(_idController.text),
                situacao: _situacaoController.text
              )
            )
          ), // Nome Técnicos
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SearchTextField(
                  hint: 'Id',
                  keyboardType: TextInputType.number,
                  controller: _idController,
                  onChangedAction: (String id) => _tecnicoBloc.add(
                    TecnicoSearchEvent(
                      nome: _nomeController.text,
                      id: int.tryParse(id),
                      situacao: _situacaoController.text
                    )
                  )
                ),
              ), // Id Técnicos
              Expanded(
                flex: 5,
                child: CustomSearchDropDown(
                  label: "Situação",
                  dropdownValues: Constants.situationTecnicoList,
                  controller: _situacaoController,
                  searchDecoration: true,
                  leftPadding: 0,
                  suggestionVerticalOffset: 0,
                  onChanged: (situacao) => _tecnicoBloc.add(
                    TecnicoSearchEvent(
                      id: int.tryParse(_idController.text),
                      nome: _nomeController.text,
                      situacao: _situacaoController.text
                    )
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
            child: BlocBuilder<TecnicoBloc, TecnicoState>(
              bloc: _tecnicoBloc,
              builder: (context, state) {
                return switch(state) {
                  TecnicoInitialState() ||
                  TecnicoLoadingState() => const Center(child: CircularProgressIndicator.adaptive()),
                  
                  TecnicoSearchSuccessState() => SuperListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    scrollDirection: Axis.vertical,
                    itemCount: state.tecnicos.length,
                    itemBuilder: (context, index) {
                      final Tecnico tecnico = state.tecnicos[index];
                      final int id = tecnico.id!;
                      final bool editable = (isSelected && _selectedItems.length == 1 && _selectedItems.contains(id));
                      // TODO - Criar um componente para o ListTile
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: ListTile(
                          leading: Text(
                            "$id", 
                            style: const TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          title: Text(
                            "${tecnico.nome} ${tecnico.sobrenome}", 
                            style: const TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          subtitle: Text(Constants.transformTelefone(tecnico: tecnico)),
                          trailing: (editable) ? _buildEditableSection(id) : Text(tecnico.situacao.toString()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          tileColor: const Color.fromRGBO(239, 239, 239, 100),
                          selectedTileColor: Colors.blue.withOpacity(.5),
                          selected: _selectedItems.contains(id),
                          onLongPress: () => _selectItems(id),
                          onTap: () {
                            if (_selectedItems.isNotEmpty) {
                              _selectItems(id);
                            }
                            if (_selectedItems.isEmpty) {
                              isSelected = false;
                            }
                          },
                        ),
                      );
                    },
                  ),
                  
                  _ => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.not_interested, size: 30),
                      const SizedBox(height: 16),
                      Text("Aconteceu um erro!!")
                    ],
                  )
                };
              },
            ),
          )
        ]
      )
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _situacaoController.dispose();
    _tecnicoBloc.close();
    super.dispose();
  }
}