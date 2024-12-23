import 'dart:async';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/card_technical.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/logic/lista/lista_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _listaBloc = context.read<ListaBloc>();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = SingleSelectController<String>(
        Constants.situationTecnicoList[1]['label']);
    _situacaoNotifier =
        ValueNotifier<String>(Constants.situationTecnicoList[1]['value']);
    _listaBloc.add(ListaInitialEvent());
  }

  void _onNavigateToUpdateScreen(int id) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UpdateTecnico(id: id),
      ),
    );
    _listaBloc.add(ListaClearSelectionEvent());
  }

  void _onLongPressSelectItemLista(int id) {
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
            ));
  }

  void _disableTecnicos(BuildContext context, List<int> selectedIds) {
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: selectedIds));
    _listaBloc.add(ListaClearSelectionEvent());
  }

  Widget _buildSearchInputs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final isMediumScreen = screenWidth >= 500 && screenWidth < 1000;
    final maxContainerWidth = 1200.0;

    Widget buildSearchField(
            {required String hint,
            TextEditingController? controller,
            TextInputType? keyboardType}) =>
        CustomSearchTextField(
          hint: hint,
          leftPadding: 4,
          rightPadding: 4,
          controller: controller,
          keyboardType: keyboardType,
          onChangedAction: (value) => _onSearchFieldChanged(),
        );

    Widget buildDropdownField(
            {required String label,
            required SingleSelectController<String> controller,
            required ValueNotifier<String> valueNotifier,
            required List<String> dropdownValues}) =>
        CustomDropdownField(
          label: label,
          dropdownValues: dropdownValues,
          controller: controller,
          valueNotifier: valueNotifier,
          leftPadding: 4,
          rightPadding: 4,
          onChanged: (selectedLabel) {
            final selectedValue = Constants.situationTecnicoList
                .firstWhere((e) => e['label'] == selectedLabel)['value'];
            _tecnicoBloc.add(
              TecnicoSearchEvent(
                id: int.tryParse(_idController.text),
                nome: _nomeController.text,
                situacao: selectedValue,
              ),
            );
          },
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
                dropdownValues: Constants.situationTecnicoList
                    .map((e) => e['label'] as String)
                    .toList(),
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
                    dropdownValues: Constants.situationTecnicoList
                        .map((e) => e['label'] as String)
                        .toList(),
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
              dropdownValues: Constants.situationTecnicoList
                  .map((e) => e['label'] as String)
                  .toList(),
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
          final bool hasSelection =
              state is ListaSelectState && state.selectedIds.isNotEmpty;

          return !hasSelection
              ? BuildWidgets.buildFabAdd(
                  context,
                  "/createTecnico",
                  () {
                    _tecnicoBloc.add(TecnicoSearchEvent());
                  },
                  tooltip: 'Adicionar um técnico',
                )
              : BuildWidgets.buildFabRemove(
                  context,
                  () {
                    _disableTecnicos(context, state.selectedIds);
                    context.read<ListaBloc>().add(ListaClearSelectionEvent());
                  },
                  tooltip: 'Excluir técnicos selecionados',
                );
        },
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<TecnicoBloc, TecnicoState>(
              builder: (context, stateTecnico) {
                if (stateTecnico is TecnicoInitialState ||
                    stateTecnico is TecnicoLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (stateTecnico is TecnicoSearchSuccessState) {
                  return SingleChildScrollView(
                    child: GridListView(
                      aspectRatio: 2.5,
                      dataList: stateTecnico.tecnicos,
                      buildCard: (tecnico) =>
                          BlocBuilder<ListaBloc, ListaState>(
                        builder: (context, stateLista) {
                          bool isSelected = false;

                          if (stateLista is ListaSelectState) {
                            isSelected =
                                stateLista.selectedIds.contains(tecnico.id);
                          }

                          return CardTechnical(
                            onDoubleTap: () =>
                                _onNavigateToUpdateScreen(tecnico.id!),
                            onLongPress: () =>
                                _onLongPressSelectItemLista(tecnico.id!),
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
