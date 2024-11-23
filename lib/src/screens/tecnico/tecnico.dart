import 'package:serv_oeste/src/components/header.dart';
import 'package:serv_oeste/src/components/sidebar_navigation.dart';
import 'package:serv_oeste/src/components/card_technical.dart';
import 'package:serv_oeste/src/components/search_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/screens/tecnico/update_tecnico.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class TecnicoPage extends StatefulWidget {
  const TecnicoPage({super.key});

  @override
  State<TecnicoPage> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoPage> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  late TextEditingController _idController,
      _nomeController,
      _telefoneFixoController,
      _telefoneCelularController,
      _situacaoController;
  late final List<int> _selectedItems;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc.add(TecnicoLoadingEvent());
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _telefoneFixoController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _situacaoController = TextEditingController();
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

  Widget _buildTechnicalCard() {
    return const CardTechnical(
      index: "1",
      name: "Lucas Adriano Tavares",
      phoneNumber: "(11)9999-9999",
      cellPhoneNumber: "(11)99999-9999",
      status: "Ativo",
    );
  }

  Widget _buildTechnicalGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400
            ? 4
            : MediaQuery.of(context).size.width > 1000
                ? 3
                : MediaQuery.of(context).size.width > 600
                    ? 2
                    : 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        return _buildTechnicalCard();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 768;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: isLargeScreen ? null : const SidebarNavigation(currentIndex: 1),
        floatingActionButton: (!isSelected)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/createTecnico").then((value) {
                    if (value == null) {
                      _tecnicoBloc.add(TecnicoSearchEvent());
                    }
                  });
                },
                tooltip: 'Adicionar um técnico',
                child: const Icon(Icons.add),
              )
            : FloatingActionButton(
                onPressed: _disableTecnicos,
                tooltip: 'Excluir técnicos selecionados',
                child: const Icon(Icons.delete),
              ),
        body: Row(
          children: [
            if (isLargeScreen) const SidebarNavigation(currentIndex: 1),
            Expanded(
                child: Column(children: [
              const HeaderComponent(),
              SearchTextField(
                hint: "Procure por Técnicos...",
                controller: _nomeController,
                onChangedAction: (String nome) {
                  _tecnicoBloc.add(
                    TecnicoSearchEvent(
                      nome: nome,
                      id: int.parse(_idController.text),
                      situacao: _situacaoController.text,
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SearchTextField(
                        hint: 'ID...',
                        keyboardType: TextInputType.number,
                        controller: _idController,
                        onChangedAction: (String id) => _tecnicoBloc.add(
                            TecnicoSearchEvent(
                                nome: _nomeController.text,
                                id: int.tryParse(id),
                                situacao: _situacaoController.text))),
                  ),
                  Expanded(
                    flex: 5,
                    child: CustomSearchDropDown(
                      label: "Situação...",
                      dropdownValues: Constants.situationTecnicoList,
                      controller: _situacaoController,
                      searchDecoration: true,
                      leftPadding: 0,
                      suggestionVerticalOffset: 0,
                      onChanged: (situacao) => _tecnicoBloc.add(
                          TecnicoSearchEvent(
                              id: int.tryParse(_idController.text),
                              nome: _nomeController.text,
                              situacao: _situacaoController.text)),
                    ),
                  ),
                ],
              ),
              Flexible(
                flex: 1,
                child: BlocBuilder<TecnicoBloc, TecnicoState>(
                  bloc: _tecnicoBloc,
                  builder: (context, state) {
                    return switch (state) {
                      TecnicoInitialState() ||
                      TecnicoLoadingState() =>
                        const Center(
                            child: CircularProgressIndicator.adaptive()),
                      TecnicoSearchSuccessState() => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTechnicalGrid(context),
                        ),
                      _ => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.not_interested, size: 30),
                            const SizedBox(height: 16),
                            const Text("Aconteceu um erro!!"),
                          ],
                        )
                    };
                  },
                ),
              )
            ]))
          ],
        ));
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _telefoneFixoController.dispose();
    _telefoneCelularController.dispose();
    _situacaoController.dispose();
    _tecnicoBloc.close();
    super.dispose();
  }
}
