import 'dart:async';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/card_technical.dart';
import 'package:serv_oeste/src/components/custom_search_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/util/buildwidgets.dart';

class TecnicoScreen extends StatefulWidget {
  const TecnicoScreen({super.key});

  @override
  State<TecnicoScreen> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoScreen> {
  late final TecnicoBloc _tecnicoBloc;
  late TextEditingController _idController, _nomeController;
  late SingleSelectController<String> _situacaoController;
  late ValueNotifier<String> _situacaoNotifier;
  late final List<int> _selectedItems;
  bool isSelected = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = SingleSelectController<String>('Ativo');
    _situacaoNotifier = ValueNotifier<String>('Ativo');
    _selectedItems = [];
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

  // Widget _buildEditableSection(int id) => IconButton(
  //   onPressed: () {
  //     setState(() {
  //       _selectedItems.clear();
  //       isSelected = false;
  //     });
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTecnico(id: id)))
  //       .then((value) {
  //         if(value == null) {
  //           _tecnicoBloc.add(TecnicoSearchEvent());
  //         }
  //       }
  //     );
  //   },
  //   icon: const Icon(Icons.edit, color: Colors.white),
  //   style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
  // );

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
          leftPadding: 0,
          rightPadding: 8,
          controller: controller,
          keyboardType: keyboardType,
          onChangedAction: (value) => _onSearchFieldChanged(),
        );

    Widget buildDropdownField({
      required String hint,
      required SingleSelectController<String> controller,
      required ValueNotifier<String> valueNotifier,
      required List<String> dropdownValues,
    }) =>
        CustomDropdownField(
          label: hint,
          dropdownValues: dropdownValues,
          controller: controller,
          valueNotifier: valueNotifier,
          leftPadding: 0,
          rightPadding: 8,
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
                hint: "Situação...",
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
                    hint: "Situação...",
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
            buildSearchField(
              hint: 'ID...',
              keyboardType: TextInputType.number,
              controller: _idController,
            ),
            buildDropdownField(
              hint: "Situação...",
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
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocBuilder<TecnicoBloc, TecnicoState>(
              builder: (context, state) {
                if (state is TecnicoInitialState ||
                    state is TecnicoLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                } else if (state is TecnicoSearchSuccessState) {
                  return SingleChildScrollView(
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
                          isSelected: _selectedItems.contains(tecnico.id),
                        ),
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
//TODO - Arrumar a parte de selecionar um card em que o Floating Action Button não volta para o estado padrão de adicianar quando nada está selecionado
//TODO - Tentar passar toda a lógica de selecionamento de cards para um Bloc/Cubit