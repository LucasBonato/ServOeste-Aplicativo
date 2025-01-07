import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class CreateCliente extends StatefulWidget {
  const CreateCliente({super.key});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {
  late final ClienteBloc _clienteBloc;
  final EnderecoBloc _enderecoBloc = EnderecoBloc();
  final ClienteForm _clienteCreateForm = ClienteForm();
  final ClienteValidator _clienteCreateValidator = ClienteValidator();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  late final TextEditingController _municipioController;
  List<String> _dropdownValuesNomes = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _clienteBloc = context.read<ClienteBloc>();
    _municipioController = TextEditingController();
  }

  void _onNomeChanged(String nome) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchClienteNames(nome));
  }

  void _fetchClienteNames(String nome) async {
    _clienteCreateForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownValuesNomes.isEmpty) return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
  }

  void _fetchInformationAboutCep(String? cep) async {
    if (cep?.length != 9) return;
    _clienteCreateForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response =
        _clienteCreateValidator.validate(_clienteCreateForm);
    return response.isValid;
  }

  void _registerCliente() {
    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _clienteCreateForm.nome.value.split(" ");
    _clienteCreateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _clienteBloc.add(ClienteRegisterEvent(
        cliente: Cliente.fromForm(_clienteCreateForm), sobrenome: sobrenome));
    _clienteCreateForm.nome.value = "${nomes.first} $sobrenome";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente adicionado com sucesso!')),
    );
  }

  void _handleBackNavigation() {
    _clienteBloc.add(ClienteSearchEvent());
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
            padding: const EdgeInsets.all(12),
            child: ScrollConfiguration(
              behavior: ScrollBehavior()
                  .copyWith(overscroll: false, scrollbars: false),
              child: SingleChildScrollView(
                child: Form(
                  key: _clienteFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Adicionar Cliente",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 48),
                      BlocListener<ClienteBloc, ClienteState>(
                        bloc: _clienteBloc,
                        listener: (context, state) {
                          if (state is ClienteSearchSuccessState) {
                            List<String> nomes = state.clientes
                                .take(5)
                                .map((cliente) => cliente.nome!)
                                .toList();

                            if (_dropdownValuesNomes != nomes) {
                              setState(() {
                                _dropdownValuesNomes = nomes;
                              });
                            }
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSearchDropDown(
                              label: "Nome*",
                              maxLength: 40,
                              dropdownValues: _dropdownValuesNomes,
                              leftPadding: 4,
                              rightPadding: 4,
                              validator: _clienteCreateValidator.byField(
                                _clienteCreateForm,
                                ErrorCodeKey.nomeESobrenome.name,
                              ),
                              onChanged: _onNomeChanged,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Transform.translate(
                                offset: Offset(24, -18),
                                child: Text(
                                  "Obs. os nomes que aparecerem já estão cadastrados",
                                  style: TextStyle(
                                    fontSize:
                                        (MediaQuery.of(context).size.width *
                                                0.04)
                                            .clamp(9.0, 13.0),
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 400) {
                                  return Column(
                                    children: [
                                      CustomTextFormField(
                                        hint: "(99) 9999-9999",
                                        label: "Telefone Fixo**",
                                        type: TextInputType.phone,
                                        maxLength: 14,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        hide: true,
                                        masks: InputMasks.maskTelefoneFixo,
                                        valueNotifier:
                                            _clienteCreateForm.telefoneFixo,
                                        validator:
                                            _clienteCreateValidator.byField(
                                                _clienteCreateForm,
                                                ErrorCodeKey.telefones.name),
                                        onChanged:
                                            _clienteCreateForm.setTelefoneFixo,
                                      ),
                                      CustomTextFormField(
                                        valueNotifier:
                                            _clienteCreateForm.telefoneCelular,
                                        hint: "(99) 99999-9999",
                                        label: "Telefone Celular**",
                                        masks: InputMasks.maskCelular,
                                        maxLength: 15,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        type: TextInputType.phone,
                                        hide: true,
                                        validator:
                                            _clienteCreateValidator.byField(
                                                _clienteCreateForm,
                                                ErrorCodeKey.telefones.name),
                                        onChanged: _clienteCreateForm
                                            .setTelefoneCelular,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          hint: "(99) 9999-9999",
                                          label: "Telefone Fixo**",
                                          type: TextInputType.phone,
                                          leftPadding: 4,
                                          rightPadding: 4,
                                          maxLength: 14,
                                          hide: true,
                                          masks: InputMasks.maskTelefoneFixo,
                                          valueNotifier:
                                              _clienteCreateForm.telefoneFixo,
                                          validator:
                                              _clienteCreateValidator.byField(
                                                  _clienteCreateForm,
                                                  ErrorCodeKey.telefones.name),
                                          onChanged: _clienteCreateForm
                                              .setTelefoneFixo,
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomTextFormField(
                                          valueNotifier: _clienteCreateForm
                                              .telefoneCelular,
                                          hint: "(99) 99999-9999",
                                          label: "Telefone Celular**",
                                          masks: InputMasks.maskCelular,
                                          leftPadding: 4,
                                          rightPadding: 4,
                                          maxLength: 15,
                                          type: TextInputType.phone,
                                          hide: true,
                                          validator:
                                              _clienteCreateValidator.byField(
                                                  _clienteCreateForm,
                                                  ErrorCodeKey.telefones.name),
                                          onChanged: _clienteCreateForm
                                              .setTelefoneCelular,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                BlocListener<EnderecoBloc, EnderecoState>(
                                  bloc: _enderecoBloc,
                                  listener: (context, state) {
                                    if (state is EnderecoSuccessState) {
                                      _clienteCreateForm
                                          .setBairro(state.bairro);
                                      _clienteCreateForm.setRua(state.rua);
                                      _clienteCreateForm
                                          .setMunicipio(state.municipio);
                                      _municipioController.text =
                                          state.municipio;
                                    }
                                  },
                                  child: CustomTextFormField(
                                    hint: "00000-000",
                                    label: "CEP",
                                    type: TextInputType.number,
                                    maxLength: 9,
                                    hide: true,
                                    leftPadding: 4,
                                    rightPadding: 4,
                                    masks: InputMasks.maskCep,
                                    valueNotifier: _clienteCreateForm.cep,
                                    validator: _clienteCreateValidator.byField(
                                        _clienteCreateForm,
                                        ErrorCodeKey.cep.name),
                                    onChanged: _fetchInformationAboutCep,
                                  ),
                                ),
                                CustomSearchDropDown(
                                  label: "Município*",
                                  dropdownValues: Constants.municipios,
                                  leftPadding: 4,
                                  rightPadding: 4,
                                  controller: _municipioController,
                                  validator: _clienteCreateValidator.byField(
                                      _clienteCreateForm,
                                      ErrorCodeKey.municipio.name),
                                  onChanged: _clienteCreateForm.setMunicipio,
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                      BlocListener<EnderecoBloc, EnderecoState>(
                                    bloc: _enderecoBloc,
                                    listener: (context, state) {
                                      if (state is EnderecoSuccessState) {
                                        _clienteCreateForm
                                            .setBairro(state.bairro);
                                        _clienteCreateForm.setRua(state.rua);
                                        _clienteCreateForm
                                            .setMunicipio(state.municipio);
                                        _municipioController.text =
                                            state.municipio;
                                      }
                                    },
                                    child: CustomTextFormField(
                                      hint: "00000-000",
                                      label: "CEP",
                                      type: TextInputType.number,
                                      maxLength: 9,
                                      rightPadding: 4,
                                      leftPadding: 4,
                                      hide: true,
                                      masks: InputMasks.maskCep,
                                      valueNotifier: _clienteCreateForm.cep,
                                      validator:
                                          _clienteCreateValidator.byField(
                                              _clienteCreateForm,
                                              ErrorCodeKey.cep.name),
                                      onChanged: _fetchInformationAboutCep,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: CustomSearchDropDown(
                                    label: "Município*",
                                    dropdownValues: Constants.municipios,
                                    leftPadding: 4,
                                    rightPadding: 4,
                                    controller: _municipioController,
                                    validator: _clienteCreateValidator.byField(
                                        _clienteCreateForm,
                                        ErrorCodeKey.municipio.name),
                                    onChanged: _clienteCreateForm.setMunicipio,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      CustomTextFormField(
                        hint: "Bairro...",
                        label: "Bairro*",
                        type: TextInputType.text,
                        maxLength: 255,
                        hide: true,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _clienteCreateForm.bairro,
                        validator: _clienteCreateValidator.byField(
                            _clienteCreateForm, ErrorCodeKey.bairro.name),
                        onChanged: _clienteCreateForm.setBairro,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 400) {
                            return Column(
                              children: [
                                CustomTextFormField(
                                  hint: "Rua...",
                                  label: "Rua*",
                                  type: TextInputType.text,
                                  maxLength: 255,
                                  hide: true,
                                  leftPadding: 4,
                                  rightPadding: 4,
                                  valueNotifier: _clienteCreateForm.rua,
                                  validator: _clienteCreateValidator.byField(
                                      _clienteCreateForm,
                                      ErrorCodeKey.rua.name),
                                  onChanged: _clienteCreateForm.setRua,
                                ),
                                CustomTextFormField(
                                  hint: "Número...",
                                  label: "Número*",
                                  type: TextInputType.text,
                                  maxLength: 10,
                                  hide: true,
                                  leftPadding: 4,
                                  rightPadding: 4,
                                  valueNotifier: _clienteCreateForm.numero,
                                  validator: _clienteCreateValidator.byField(
                                      _clienteCreateForm,
                                      ErrorCodeKey.numero.name),
                                  onChanged: _clienteCreateForm.setNumero,
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: CustomTextFormField(
                                    hint: "Rua...",
                                    label: "Rua*",
                                    type: TextInputType.text,
                                    maxLength: 255,
                                    rightPadding: 4,
                                    leftPadding: 4,
                                    hide: true,
                                    valueNotifier: _clienteCreateForm.rua,
                                    validator: _clienteCreateValidator.byField(
                                        _clienteCreateForm,
                                        ErrorCodeKey.rua.name),
                                    onChanged: _clienteCreateForm.setRua,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CustomTextFormField(
                                    hint: "Número...",
                                    label: "Número*",
                                    type: TextInputType.text,
                                    maxLength: 10,
                                    leftPadding: 4,
                                    rightPadding: 4,
                                    hide: true,
                                    valueNotifier: _clienteCreateForm.numero,
                                    validator: _clienteCreateValidator.byField(
                                        _clienteCreateForm,
                                        ErrorCodeKey.numero.name),
                                    onChanged: _clienteCreateForm.setNumero,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      CustomTextFormField(
                        hint: "Complemento...",
                        label: "Complemento",
                        type: TextInputType.text,
                        maxLength: 255,
                        hide: false,
                        leftPadding: 4,
                        rightPadding: 4,
                        valueNotifier: _clienteCreateForm.complemento,
                        validator: _clienteCreateValidator.byField(
                            _clienteCreateForm, ErrorCodeKey.complemento.name),
                        onChanged: _clienteCreateForm.setComplemento,
                      ),
                      const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: BuildFieldLabels()),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 750),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 16, 0, 128),
                              child: BlocListener<ClienteBloc, ClienteState>(
                                bloc: _clienteBloc,
                                listener: (context, state) {
                                  if (state is ClienteRegisterSuccessState) {
                                    _handleBackNavigation();
                                  } else if (state is ClienteErrorState) {
                                    ErrorEntity error = state.error;

                                    _clienteCreateValidator
                                        .applyBackendError(error);
                                    _clienteFormKey.currentState?.validate();
                                    _clienteCreateValidator
                                        .cleanExternalErrors();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "[ERROR] Informação(ões) inválida(s) ao registrar o Cliente.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ElevatedButton(
                                  onPressed: _registerCliente,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007BFF),
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Adicionar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    _enderecoBloc.close();
    _debounce?.cancel();
    super.dispose();
  }
}
