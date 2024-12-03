import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/card_technical.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';

class TecnicoScreen extends StatefulWidget {
  const TecnicoScreen({super.key});

  @override
  State<TecnicoScreen> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoScreen> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  late TextEditingController _idController, _nomeController;
  late SingleSelectController<String> _situacaoController;
  late ValueNotifier<String> _situacaoNotifier;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = SingleSelectController<String>('Ativo');
    _situacaoNotifier = ValueNotifier<String>('Ativo');
    _selectedItems = [];
  }

  void _disableTecnicos() {
    final List<int> selectedItemsCopy = List<int>.from(_selectedItems);
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: selectedItemsCopy));
    setState(() {
      _selectedItems.clear();
      isSelected = false;
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
        onPressed: () {
          setState(() {
            _selectedItems.clear();
            isSelected = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateTecnico(id: id))).then((value) {
            if (value == null) {
              _tecnicoBloc.add(TecnicoSearchEvent());
            }
          });
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
      );

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final maxContainerWidth = 1200.0;

    return Center(
      child: Container(
        width: isLargeScreen ? maxContainerWidth : double.infinity,
        padding: const EdgeInsets.all(5),
        child: isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SearchTextField(
                      hint: "Procure por Técnicos...",
                      controller: _nomeController,
                      onChangedAction: (String nome) => _tecnicoBloc.add(
                        TecnicoSearchEvent(
                          nome: nome,
                          id: int.tryParse(_idController.text),
                          situacao: _situacaoNotifier.value,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SearchTextField(
                      hint: 'ID...',
                      keyboardType: TextInputType.number,
                      controller: _idController,
                      leftPadding: 0,
                      onChangedAction: (String id) => _tecnicoBloc.add(
                        TecnicoSearchEvent(
                          nome: _nomeController.text,
                          id: int.tryParse(id),
                          situacao: _situacaoNotifier.value,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: CustomDropdownField(
                      label: "Situação...",
                      dropdownValues: Constants.situationTecnicoList,
                      controller: _situacaoController,
                      valueNotifier: _situacaoNotifier,
                      leftPadding: 0,
                      onChanged: (situacao) {
                        _situacaoNotifier.value = situacao ?? 'Ativo';
                        _tecnicoBloc.add(
                          TecnicoSearchEvent(
                            id: int.tryParse(_idController.text),
                            nome: _nomeController.text,
                            situacao: situacao,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : isMediumScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: SearchTextField(
                          hint: "Procure por Técnicos...",
                          controller: _nomeController,
                          onChangedAction: (String nome) {
                            _tecnicoBloc.add(
                              TecnicoSearchEvent(
                                nome: nome,
                                id: int.tryParse(_idController.text),
                                situacao: _situacaoNotifier.value,
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: SearchTextField(
                                hint: 'ID...',
                                keyboardType: TextInputType.number,
                                controller: _idController,
                                onChangedAction: (String id) {
                                  _tecnicoBloc.add(
                                    TecnicoSearchEvent(
                                      nome: _nomeController.text,
                                      id: int.tryParse(id),
                                      situacao: _situacaoNotifier.value,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: CustomDropdownField(
                              label: "Situação...",
                              dropdownValues: Constants.situationTecnicoList,
                              controller: _situacaoController,
                              valueNotifier: _situacaoNotifier,
                              leftPadding: 0,
                              onChanged: (situacao) {
                                _situacaoNotifier.value = situacao ?? 'Ativo';
                                _tecnicoBloc.add(
                                  TecnicoSearchEvent(
                                    id: int.tryParse(_idController.text),
                                    nome: _nomeController.text,
                                    situacao: situacao,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: SearchTextField(
                          hint: "Procure por Técnicos...",
                          controller: _nomeController,
                          onChangedAction: (String nome) {
                            _tecnicoBloc.add(
                              TecnicoSearchEvent(
                                nome: nome,
                                id: int.tryParse(_idController.text),
                                situacao: _situacaoNotifier.value,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: SearchTextField(
                          hint: 'ID...',
                          keyboardType: TextInputType.number,
                          controller: _idController,
                          onChangedAction: (String id) {
                            _tecnicoBloc.add(
                              TecnicoSearchEvent(
                                nome: _nomeController.text,
                                id: int.tryParse(id),
                                situacao: _situacaoNotifier.value,
                              ),
                            );
                          },
                        ),
                      ),
                      CustomDropdownField(
                        label: "Situação...",
                        dropdownValues: Constants.situationTecnicoList,
                        controller: _situacaoController,
                        valueNotifier: _situacaoNotifier,
                        onChanged: (situacao) {
                          _situacaoNotifier.value = situacao ?? 'Ativo';
                          _tecnicoBloc.add(
                            TecnicoSearchEvent(
                              id: int.tryParse(_idController.text),
                              nome: _nomeController.text,
                              situacao: situacao,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: (!isSelected)
          ? BuildWidgets.buildFabAdd(
              context,
              "/createTecnico",
              () => _tecnicoBloc.add(TecnicoSearchEvent()),
              tooltip: 'Adicionar um técnico',
            )
          : BuildWidgets.buildFabRemove(
              context,
              _disableTecnicos,
              tooltip: 'Excluir técnicos selecionados',
            ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildSearchInputs(),
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: BlocBuilder<TecnicoBloc, TecnicoState>(
                      bloc: _tecnicoBloc,
                      builder: (context, state) {
                        if (state is TecnicoInitialState ||
                            state is TecnicoLoadingState) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        } else if (state is TecnicoSearchSuccessState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridListView(
                              dataList: state.tecnicos,
                              buildCard: (tecnico) => GestureDetector(
                                onTap: () => _selectItems(tecnico.id!),
                                child: CardTechnical(
                                  id: (tecnico as Tecnico).id!,
                                  name: tecnico.nome!,
                                  phoneNumber: tecnico.telefoneFixo!,
                                  cellPhoneNumber: tecnico.telefoneCelular!,
                                  status: tecnico.situacao!,
                                  isSelected:
                                      _selectedItems.contains(tecnico.id),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.not_interested, size: 30),
                              const SizedBox(height: 16),
                              const Text("Aconteceu um erro!!"),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _situacaoController.dispose();
    _situacaoNotifier.dispose();
    _tecnicoBloc.close();
    super.dispose();
  }
}
