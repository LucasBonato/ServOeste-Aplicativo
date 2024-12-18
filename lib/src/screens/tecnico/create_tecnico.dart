import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/components/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_grid_checkers_form_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class CreateTecnico extends StatefulWidget {
  const CreateTecnico({super.key});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  late final TecnicoBloc _tecnicoBloc;
  final TecnicoForm _tecnicoCreateForm = TecnicoForm();
  final TecnicoValidator _tecnicoCreateValidator = TecnicoValidator();
  final GlobalKey<FormState> _tecnicoFormKey = GlobalKey<FormState>();
  List<String> _dropdownValuesNomes = [];
  Timer? _debounce;
  late TextEditingController _nomeController,
      _telefoneCelularController,
      _telefoneFixoController;

  bool validationCheckBoxes = false;

  final Map<String, bool> checkersMap = {
    "Adega": false,
    "Bebedouro": false,
    "Climatizador": false,
    "Cooler": false,
    "Frigobar": false,
    "Geladeira": false,
    "Lava Louca": false,
    "Lava Roupa": false,
    "Microondas": false,
    "Purificador": false,
    "Secadora": false,
    "Outros": false,
  };

  final Map<String, String> displayMap = {
    "Lava Louca": "Lava Louça",
  };

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _nomeController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _telefoneFixoController = TextEditingController();
  }

  bool _isValidForm() {
    _tecnicoFormKey.currentState?.validate();
    final ValidationResult response =
        _tecnicoCreateValidator.validate(_tecnicoCreateForm);

    if (!response.isValid) {
      Logger().e(response.exceptions[0].message);
    }

    return response.isValid;
  }

  void _onNomeChanged(String nome) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchTecnicoNames(nome));
  }

  void _fetchTecnicoNames(String nome) async {
    _tecnicoCreateForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownValuesNomes.isEmpty) return;
    _tecnicoBloc.add(TecnicoSearchEvent(nome: nome));
  }

  void _registerTecnico() {
    checkersMap.forEach((label, isChecked) {
      int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
      if (isChecked) {
        _tecnicoCreateForm.addConhecimentos(idConhecimento);
      } else {
        _tecnicoCreateForm.removeConhecimentos(idConhecimento);
      }
    });
    _tecnicoCreateValidator.setConhecimentos(_tecnicoCreateForm.conhecimentos.value);

    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoCreateForm.nome.value.split(" ");
    _tecnicoCreateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _tecnicoBloc.add(TecnicoRegisterEvent(
        tecnico: Tecnico.fromForm(_tecnicoCreateForm), sobrenome: sobrenome));
    _tecnicoCreateForm.nome.value = "${nomes.first} $sobrenome";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Técnico adicionado com sucesso!')),
    );
  }

  void _handleBackNavigation() {
    _tecnicoBloc.add(TecnicoSearchEvent());
    Navigator.pop(context, "Back");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _handleBackNavigation,
              )
            ],
          ),
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Color(0xFCFDFDFF),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _tecnicoFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Adicionar Técnico",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 48),
                    CustomSearchDropDown(
                      label: "Nome*",
                      maxLength: 40,
                      dropdownValues: _dropdownValuesNomes,
                      controller: _nomeController,
                      validator: _tecnicoCreateValidator.byField(
                          _tecnicoCreateForm, ErrorCodeKey.nomeESobrenome.name),
                      onChanged: _onNomeChanged,
                    ),
                    Transform.translate(
                      offset: Offset(0, -18),
                      child: Text(
                        "Obs. os nomes que aparecerem já estão cadastrados",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context)
                              .size
                              .width
                              .clamp(9.0, 13.0),
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hint: "(99) 9999-9999",
                            label: "Telefone Fixo**",
                            rightPadding: 8,
                            maxLength: 14,
                            hide: true,
                            masks: InputMasks.maskTelefoneFixo,
                            type: TextInputType.phone,
                            valueNotifier: _tecnicoCreateForm.telefoneFixo,
                            validator: _tecnicoCreateValidator.byField(
                                _tecnicoCreateForm,
                                ErrorCodeKey.telefones.name),
                            onChanged: _tecnicoCreateForm.setTelefoneFixo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            hint: "(99) 99999-9999",
                            label: "Telefone Celular**",
                            leftPadding: 0,
                            maxLength: 15,
                            hide: true,
                            masks: InputMasks.maskCelular,
                            type: TextInputType.phone,
                            valueNotifier: _tecnicoCreateForm.telefoneCelular,
                            validator: _tecnicoCreateValidator.byField(
                                _tecnicoCreateForm,
                                ErrorCodeKey.telefones.name),
                            onChanged: _tecnicoCreateForm.setTelefoneCelular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            "Conhecimentos*",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomGridCheckersFormField(
                          validator: _tecnicoCreateValidator.byField(_tecnicoCreateForm, ErrorCodeKey.conhecimento.name),
                          checkersMap: checkersMap,
                        ),
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.only(top: 8, left: 16),
                        child: BuildFieldLabels()),
                    const SizedBox(height: 32),
                    BlocListener<TecnicoBloc, TecnicoState>(
                      bloc: _tecnicoBloc,
                      listener: (context, state) {
                        if (state is TecnicoSearchSuccessState) {
                          List<String> nomes = state.tecnicos
                              .take(5)
                              .map((tecnico) =>
                                  '${tecnico.nome} ${tecnico.sobrenome}')
                              .toList();

                          setState(() {
                            _dropdownValuesNomes = nomes;
                          });
                        } else if (state is TecnicoRegisterSuccessState) {
                          _handleBackNavigation();
                        } else if (state is TecnicoErrorState) {
                          ErrorEntity error = state.error;

                          _tecnicoCreateValidator.applyBackendError(error);
                          _tecnicoFormKey.currentState?.validate();
                          _tecnicoCreateValidator.cleanExternalErrors();

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "[ERROR] Informação(ões) inválida(s) ao registrar o Técnico: ${error.errorMessage}")));
                        }
                      },
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _registerTecnico,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            "Adicionar Técnico",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneCelularController.dispose();
    _telefoneFixoController.dispose();
    _tecnicoCreateForm.dispose();
    super.dispose();
  }
}
