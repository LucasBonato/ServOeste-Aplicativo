import 'dart:async';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/screen/fab_add.dart';
import 'package:serv_oeste/src/components/screen/fab_remove.dart';
import 'package:serv_oeste/src/components/screen/grid_view.dart';
import 'package:serv_oeste/src/components/screen/card_technical.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/routes.dart';

class TecnicoScreen extends StatefulWidget {
  const TecnicoScreen({super.key});

  @override
  State<TecnicoScreen> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoScreen> {
  late final ListaBloc _listaBloc;
  late final TecnicoBloc _tecnicoBloc;
  late TextEditingController _idController, _nomeController;
  late SingleSelectController<String> _situacaoController;
  late ValueNotifier<String> _situacaoNotifier;
  bool isTheFirstSelection = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _listaBloc = context.read<ListaBloc>();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = SingleSelectController<String>(Constants.situationTecnicoList.first);
    _situacaoNotifier = ValueNotifier<String>(Constants.situationTecnicoList.first);
    _listaBloc.add(ListaInitialEvent());
    _setFilterValues();
  }

  void _setFilterValues() {
    _idController.text = (_tecnicoBloc.id == null) ? "" : _tecnicoBloc.id.toString();
    _nomeController.text = _tecnicoBloc.nome?? "";
    String situacao = (_tecnicoBloc.situacao != null) ? _tecnicoBloc.situacao![0].toUpperCase() + _tecnicoBloc.situacao!.substring(1) : "";
    if (situacao != "" && Constants.situationTecnicoList.contains(situacao)) {
      _situacaoNotifier.value = situacao;
      _situacaoController = SingleSelectController<String>(situacao);
    }
  }

  void _onNavigateToUpdateScreen(int id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UpdateTecnico(id: id),
      ),
    );
    _listaBloc.add(ListaClearSelectionEvent());
  }

  void _onSelectItemList(int id) {
    _listaBloc.add(ListaToggleItemSelectEvent(id: id));
  }

  void _onSearchFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(
      Duration(milliseconds: 150),
      () => _tecnicoBloc.add(
        TecnicoSearchEvent(
          nome: _nomeController.text,
          id: int.tryParse(_idController.text),
          situacao: _situacaoNotifier.value,
        ),
      ),
    );
  }

  void _disableTecnicos(BuildContext context, List<int> selectedIds) {
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: selectedIds));
    _listaBloc.add(ListaClearSelectionEvent());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Técnico desativado com sucesso!')),
    );
  }

  bool _isTecnicoSelected(int id, ListaState stateLista) {
    if (stateLista is ListaSelectState) {
      return stateLista.selectedIds.contains(id);
    }
    return false;
  }

  bool _isSelectionMode(ListaState stateLista) {
    if (stateLista is ListaSelectState) {
      return stateLista.selectedIds.isNotEmpty;
    }
    return false;
  }

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField({required String hint, TextEditingController? controller, TextInputType? keyboardType}) => CustomSearchTextFormField(
          hint: hint,
          leftPadding: 4,
          rightPadding: 4,
          controller: controller,
          keyboardType: keyboardType,
          onChangedAction: (value) => _onSearchFieldChanged(),
        );

    Widget buildDropdownField(
            {required String label, required SingleSelectController<String> controller, required ValueNotifier<String> valueNotifier, required List<String> dropdownValues}) =>
        CustomDropdownFormField(
          label: label,
          dropdownValues: dropdownValues,
          controller: controller,
          valueNotifier: valueNotifier,
          leftPadding: 4,
          rightPadding: 4,
          onChanged: (situacao) => _tecnicoBloc.add(
            TecnicoSearchEvent(
              id: int.tryParse(_idController.text),
              nome: _nomeController.text,
              situacao: situacao,
            ),
          ),
        );

    Widget buildLargeScreenLayout() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: buildSearchField(
                hint: "Procure por Técnicos...",
                controller: _nomeController,
              ),
            ),
            Expanded(
              flex: 1,
              child: buildSearchField(
                hint: 'ID...',
                keyboardType: TextInputType.number,
                controller: _idController,
              ),
            ),
            Expanded(
              flex: 1,
              child: buildDropdownField(
                label: "Situação...",
                dropdownValues: Constants.situationTecnicoList,
                controller: _situacaoController,
                valueNotifier: _situacaoNotifier,
              ),
            ),
          ],
        );

    Widget buildMediumScreenLayout() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSearchField(
              hint: "Procure por Técnicos...",
              controller: _nomeController,
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: buildSearchField(
                    hint: 'ID...',
                    keyboardType: TextInputType.number,
                    controller: _idController,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: buildDropdownField(
                    label: "Situação...",
                    dropdownValues: Constants.situationTecnicoList,
                    controller: _situacaoController,
                    valueNotifier: _situacaoNotifier,
                  ),
                ),
              ],
            ),
          ],
        );

    Widget buildSmallScreenLayout() => Column(
          children: [
            buildSearchField(
              hint: "Procure por Técnicos...",
              controller: _nomeController,
            ),
            SizedBox(height: 5),
            buildSearchField(
              hint: 'ID...',
              keyboardType: TextInputType.number,
              controller: _idController,
            ),
            SizedBox(height: 5),
            buildDropdownField(
              label: "Situação...",
              dropdownValues: Constants.situationTecnicoList,
              controller: _situacaoController,
              valueNotifier: _situacaoNotifier,
            ),
          ],
        );

    return Center(
      child: Container(
        width: isLargeScreen ? maxContainerWidth : double.infinity,
        padding: const EdgeInsets.all(5),
        child: isLargeScreen
            ? buildLargeScreenLayout()
            : isMediumScreen
                ? buildMediumScreenLayout()
                : buildSmallScreenLayout(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: BlocBuilder<ListaBloc, ListaState>(
        builder: (context, state) {
          final bool hasSelection = state is ListaSelectState && state.selectedIds.isNotEmpty;

          return (!hasSelection)
              ? FloatingActionButtonAdd(route: Routes.tecnicoCreate, event: () => _tecnicoBloc.add(TecnicoSearchEvent()), tooltip: "Adicionar um Técnico")
              : FloatingActionButtonRemove(
                  removeMethod: () {
                    _disableTecnicos(context, state.selectedIds);
                    context.read<ListaBloc>().add(ListaClearSelectionEvent());
                  },
                  tooltip: "Excluir técnicos selecionados",
                );
        },
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<TecnicoBloc, TecnicoState>(
              builder: (context, stateTecnico) {
                if (stateTecnico is TecnicoInitialState || stateTecnico is TecnicoLoadingState) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                } else if (stateTecnico is TecnicoSearchSuccessState) {
                  if (stateTecnico.tecnicos.isNotEmpty) {
                    return SingleChildScrollView(
                      child: GridListView(
                        aspectRatio: 2.5,
                        dataList: stateTecnico.tecnicos,
                        buildCard: (tecnico) => BlocBuilder<ListaBloc, ListaState>(
                          builder: (context, stateLista) {
                            final bool isSelected = _isTecnicoSelected(tecnico.id, stateLista);
                            final bool isSelectionMode = _isSelectionMode(stateLista);

                            return CardTechnician(
                              onDoubleTap: () => _onNavigateToUpdateScreen(tecnico.id!),
                              onLongPress: () => _onSelectItemList(tecnico.id),
                              onTap: () {
                                if (isSelectionMode) {
                                  _onSelectItemList(tecnico.id);
                                }
                              },
                              id: tecnico.id!,
                              nome: tecnico.nome!,
                              sobrenome: tecnico.sobrenome!,
                              telefone: tecnico.telefoneFixo!,
                              celular: tecnico.telefoneCelular!,
                              status: tecnico.situacao!,
                              isSelected: isSelected,
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Nenhum técnico encontrado.",
                          style: TextStyle(fontSize: 18.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.not_interested, size: 30),
                    const SizedBox(height: 16),
                    const Text("Aconteceu um erro!!"),
                  ],
                );
              },
            ),
          ),
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
    _debounce?.cancel();
    super.dispose();
  }
}
