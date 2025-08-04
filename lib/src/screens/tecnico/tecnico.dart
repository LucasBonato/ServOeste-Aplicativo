import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/layout/fab_add.dart';
import 'package:serv_oeste/src/components/layout/fab_remove.dart';
import 'package:serv_oeste/src/components/layout/pagination_widget.dart';
import 'package:serv_oeste/src/components/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/src/components/screen/cards/card_technical.dart';
import 'package:serv_oeste/src/components/screen/entity_not_found.dart';
import 'package:serv_oeste/src/components/screen/error_component.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_response.dart';
import 'package:serv_oeste/src/screens/base_list_screen.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/routes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TecnicoScreen extends BaseListScreen<TecnicoResponse> {
  const TecnicoScreen({super.key});

  @override
  BaseListScreenState<TecnicoResponse> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends BaseListScreenState<TecnicoResponse> {
  late final TecnicoBloc _tecnicoBloc;
  late TextEditingController _idController, _nomeController;
  late SingleSelectController<String> _situacaoController;
  late ValueNotifier<String> _situacaoNotifier;

  void _setFilterValues() {
    _idController.text = (_tecnicoBloc.idMenu == null) ? "" : _tecnicoBloc.idMenu.toString();
    _nomeController.text = _tecnicoBloc.nomeMenu ?? "";
    String situacao = (_tecnicoBloc.situacaoMenu != null) ? _tecnicoBloc.situacaoMenu![0].toUpperCase() + _tecnicoBloc.situacaoMenu!.substring(1) : "";
    if (situacao != "" && Constants.situationTecnicoList.contains(situacao)) {
      setState(() {
        _situacaoNotifier.value = situacao;
        _situacaoController = SingleSelectController<String>(situacao);
      });
    }
  }

  Widget _buildSearchInputs() {
    return ResponsiveSearchInputs(
      onChanged: onSearchFieldChanged,
      fields: [
        TextInputField(
            hint: "Procure por Técnicos...",
            controller: _nomeController,
            keyboardType: TextInputType.text
        ),
        TextInputField(
            hint: "ID...",
            controller: _idController,
            keyboardType: TextInputType.number
        ),
        DropdownInputField(
            hint: "Situação...",
            controller: _situacaoController,
            valueNotifier: _situacaoNotifier,
            dropdownValues: Constants.situationTecnicoList,
            onChanged: (situacao) =>
                _tecnicoBloc.add(
                  TecnicoSearchMenuEvent(
                    id: int.tryParse(_idController.text),
                    nome: _nomeController.text,
                    situacao: situacao,
                  ),
                )
        ),
      ],
    );
  }

  @override
  Widget getUpdateScreen(int id) => UpdateTecnico(id: id);

  @override
  Widget buildDefaultFloatingActionButton() {
    return FloatingActionButtonAdd(
      route: Routes.tecnicoCreate,
      event: () => _tecnicoBloc.add(TecnicoSearchMenuEvent()),
      tooltip: "Adicionar um Técnico"
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) {
    return FloatingActionButtonRemove(
      removeMethod: () => disableSelectedItems(context, selectedIds),
      tooltip: "Excluir técnicos selecionados",
    );
  }

  @override
  Widget buildItemCard(TecnicoResponse tecnico, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return CardTechnician(
      onDoubleTap: () => onNavigateToUpdateScreen(tecnico.id!, () => _tecnicoBloc.add(TecnicoSearchMenuEvent())),
      onLongPress: () => onSelectItemList(tecnico.id!),
      onTap: () {
        if (isSelectMode) {
          onSelectItemList(tecnico.id!);
        }
      },
      id: tecnico.id!,
      nome: tecnico.nome!,
      sobrenome: tecnico.sobrenome!,
      telefone: tecnico.telefoneFixo!,
      celular: tecnico.telefoneCelular!,
      status: tecnico.situacao!,
      isSelected: isSelected,
      isSkeleton: isSkeleton
    );
  }

  @override
  void searchFieldChanged() {
    _tecnicoBloc.add(
      TecnicoSearchMenuEvent(
        nome: _nomeController.text,
        id: int.tryParse(_idController.text),
        situacao: _situacaoNotifier.value,
      ),
    );
  }

  @override
  void onDisableItems(List<int> selectedIds) {
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: selectedIds));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Técnico desativado com sucesso!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _situacaoController = SingleSelectController<String>(Constants.situationTecnicoList.first);
    _situacaoNotifier = ValueNotifier<String>(Constants.situationTecnicoList.first);
    _setFilterValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: buildFloatingActionButton(),
      body: Column(
        children: [
          _buildSearchInputs(),
          Expanded(
            child: BlocListener<TecnicoBloc, TecnicoState>(
              listenWhen: (previous, current) => current is TecnicoErrorState,
              listener: (context, state) {
                if (state is TecnicoErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error.errorMessage),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }
              },
              child: BlocBuilder<TecnicoBloc, TecnicoState>(
                builder: (context, stateTecnico) {
                  if (stateTecnico is TecnicoInitialState || stateTecnico is TecnicoLoadingState) {
                    return Skeletonizer(
                      enableSwitchAnimation: true,
                      child: buildGridOfCards(
                        List.generate(20, (_) => TecnicoResponse()..applySkeletonData()),
                        2.5,
                        isSkeleton: true,
                      ),
                    );
                  }
                  else if (stateTecnico is TecnicoSearchSuccessState) {
                    return Column(
                      children: [
                        Expanded(
                          child: stateTecnico.tecnicos.isNotEmpty
                              ? buildGridOfCards(stateTecnico.tecnicos, 2.5)
                              : const EntityNotFound(
                                  message: "Nenhum técnico encontrado."),
                        ),
                        if (stateTecnico.totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: PaginationWidget(
                              currentPage: stateTecnico.currentPage + 1,
                              totalPages: stateTecnico.totalPages,
                              onPageChanged: (page) {
                                _tecnicoBloc.add(TecnicoLoadingEvent(
                                  id: _tecnicoBloc.idMenu,
                                  nome: _tecnicoBloc.nomeMenu,
                                  situacao: _tecnicoBloc.situacaoMenu,
                                  equipamento: null,
                                  page: page - 1,
                                  size: 20,
                                ));
                              },
                            ),
                          ),
                      ],
                    );
                  }
                  return const ErrorComponent();
                },
              ),
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
    super.dispose();
  }
}
