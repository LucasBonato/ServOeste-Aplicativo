import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:serv_oeste/core/routing/args/tecnico_update_args.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_filter.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_response.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_card.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_input_field.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_add.dart';
import 'package:serv_oeste/shared/widgets/layout/fab_remove.dart';
import 'package:serv_oeste/shared/widgets/layout/responsive_search_inputs.dart';
import 'package:serv_oeste/shared/widgets/screen/base_list_screen.dart';
import 'package:serv_oeste/shared/widgets/screen/error_component.dart';
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

  Widget _buildSearchInputs() {
    return ResponsiveSearchInputs(
      onChanged: onSearchFieldChanged,
      fields: [
        TextInputField(hint: "Procure por Técnicos...", controller: _nomeController, keyboardType: TextInputType.text),
        TextInputField(
          hint: "ID...",
          controller: _idController,
          keyboardType: TextInputType.number,
        ),
        DropdownInputField(
          hint: "Situação...",
          valueNotifier: _situacaoNotifier,
          dropdownValues: Constants.situationTecnicoList,
          onChanged: (situacao) => _tecnicoBloc.add(
            TecnicoSearchEvent(
              filter: TecnicoFilter(
                id: int.tryParse(_idController.text),
                nome: _nomeController.text,
                situacao: situacao,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  String getUpdateRoute() => Routes.tecnicoUpdate;

  @override
  Widget buildDefaultFloatingActionButton() {
    return FloatingActionButtonAdd(
      route: Routes.tecnicoCreate,
      event: () => _tecnicoBloc.add(TecnicoSearchEvent(filter: const TecnicoFilter())),
      tooltip: "Adicionar um Técnico",
    );
  }

  @override
  Widget buildSelectionFloatingActionButton(List<int> selectedIds) {
    return FloatingActionButtonRemove(
      removeMethod: () => disableSelectedItems(context, selectedIds),
      tooltip: "Excluir técnicos selecionados",
      content: 'Deletar técnicos selecionados?',
    );
  }

  @override
  Widget buildItemCard(TecnicoResponse tecnico, bool isSelected, bool isSelectMode, bool isSkeleton) {
    return TecnicoCard(
      onDoubleTap: () => onNavigateToUpdateScreen(TecnicoUpdateArgs(id: tecnico.id!), () => _tecnicoBloc.add(TecnicoSearchEvent(filter: const TecnicoFilter()))),
      onLongPress: () => onSelectItemList(tecnico.id!),
      onTap: () {
        if (isSelectMode) {
          onSelectItemList(tecnico.id!);
        }
      },
      id: tecnico.id!,
      nome: tecnico.nome!,
      sobrenome: tecnico.sobrenome!,
      telefone: tecnico.telefoneFixo,
      celular: tecnico.telefoneCelular,
      status: tecnico.situacao!,
      isSelected: isSelected,
      isSkeleton: isSkeleton,
    );
  }

  @override
  void searchFieldChanged() {
    final idText = _idController.text.trim();
    final id = idText.isEmpty ? null : int.tryParse(idText);

    _tecnicoBloc.add(
      TecnicoSearchEvent(
        filter: TecnicoFilter(
          nome: _nomeController.text,
          id: id,
          situacao: _situacaoNotifier.value,
        ),
      ),
    );
  }

  @override
  void onDisableItems(List<int> selectedIds) {
    _tecnicoBloc.add(TecnicoDisableListEvent(selectedList: selectedIds));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Técnico desativado com sucesso! (Caso ele não esteja desativado, recarregue a página)'),
        backgroundColor: Colors.green,
      ),
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
            child: BlocConsumer<TecnicoBloc, TecnicoState>(
              listenWhen: (previous, current) => current is TecnicoErrorState ||
                  (
                      current is TecnicoSearchSuccessState &&
                      previous is TecnicoSearchSuccessState &&
                      current.filter != previous.filter
                  ),
              listener: (context, state) {
                if (state is TecnicoErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Logger().e(state.error.detail);
                  });
                }
                if (state is TecnicoSearchSuccessState) {
                  final TecnicoFilter filter = state.filter;

                  _idController.text = filter.id?.toString()?? "";
                  _nomeController.text = filter.nome?? "";
                  String situacao = (filter.situacao != null) ? filter.situacao![0].toUpperCase() + filter.situacao!.substring(1) : "";
                  if (situacao != "" && Constants.situationTecnicoList.contains(situacao)) {
                    setState(() {
                      _situacaoNotifier.value = situacao;
                      _situacaoController = SingleSelectController<String>(situacao);
                    });
                  }
                }
              },
              builder: (context, stateTecnico) {
                if (stateTecnico is TecnicoInitialState || stateTecnico is TecnicoLoadingState) {
                  return Skeletonizer(
                    enableSwitchAnimation: true,
                    child: buildGridOfCards(
                      items: List.generate(16, (_) => TecnicoResponse()..applySkeletonData()),
                      aspectRatio: 2.1,
                      totalPages: 1,
                      currentPage: 0,
                      onPageChanged: (_) {},
                      isSkeleton: true,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      horizontalPadding: 16,
                      verticalPadding: 10,
                    ),
                  );
                } else if (stateTecnico is TecnicoSearchSuccessState) {
                  return buildGridOfCards(
                    items: stateTecnico.tecnicos,
                    aspectRatio: 2.1,
                    totalPages: stateTecnico.totalPages,
                    currentPage: stateTecnico.currentPage,
                    onPageChanged: (page) {
                      _tecnicoBloc.add(TecnicoSearchEvent(
                        filter: stateTecnico.filter,
                        page: page - 1,
                        size: 20,
                      ));
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1300
                          ? 4
                          : MediaQuery.of(context).size.width > 900
                              ? 3
                              : MediaQuery.of(context).size.width > 450
                                  ? 2
                                  : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.1,
                    ),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    horizontalPadding: 16,
                    verticalPadding: 10,
                  );
                }
                return const ErrorComponent();
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
    super.dispose();
  }
}
