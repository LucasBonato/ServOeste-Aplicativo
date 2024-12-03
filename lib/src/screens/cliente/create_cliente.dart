import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class CreateCliente extends StatefulWidget {
  const CreateCliente({super.key});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {
  final EnderecoBloc _enderecoBloc = EnderecoBloc();
  final ClienteBloc _clienteBloc = ClienteBloc();
  final ClienteForm _clienteCreateForm = ClienteForm();
  final ClienteValidator _clienteCreateValidator = ClienteValidator();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  List<String> _dropdownValuesNomes = [];
  Timer? _debounce;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context, "Back"),
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
                            _dropdownValuesNomes = nomes;
                            setState(() {});
                          }
                        }
                      },
                      child: CustomSearchDropDown(
                        // hint: "Nome...",
                        label: "Nome*",
                        maxLength: 40,
                        dropdownValues: _dropdownValuesNomes,
                        validator: _clienteCreateValidator.byField(
                            _clienteCreateForm, "nome"),
                        onChanged: _onNomeChanged,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hint: "(99) 9999-9999",
                            label: "Telefone Fixo**",
                            type: TextInputType.phone,
                            rightPadding: 4,
                            maxLength: 14,
                            hide: false,
                            masks: [
                              MaskTextInputFormatter(mask: '(##) ####-####'),
                            ],
                            valueNotifier: _clienteCreateForm.telefoneFixo,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "telefoneFixo"),
                            onChanged: _clienteCreateForm.setTelefoneFixo,
                          ),
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            valueNotifier: _clienteCreateForm.telefoneCelular,
                            hint: "(99) 99999-9999",
                            label: "Telefone Celular**",
                            masks: Constants.maskTelefone,
                            leftPadding: 4,
                            maxLength: 15,
                            type: TextInputType.phone,
                            hide: false,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "telefoneCelular"),
                            onChanged: _clienteCreateForm.setTelefoneCelular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hint: "00000-000",
                            label: "CEP",
                            type: TextInputType.streetAddress,
                            rightPadding: 4,
                            maxLength: 9,
                            hide: false,
                            masks: Constants.maskCep,
                            valueNotifier: _clienteCreateForm.cep,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "cep"),
                            onChanged: _fetchInformationAboutCep,
                          ),
                        ),
                        Expanded(
                          child: CustomSearchDropDown(
                            // hint: "Município...",
                            label: "Município*",
                            leftPadding: 4,
                            dropdownValues: Constants.municipios,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "municipio"),
                            onChanged: _clienteCreateForm.setMunicipio,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      hint: "Bairro...",
                      label: "Bairro*",
                      type: TextInputType.text,
                      maxLength: 40,
                      hide: true,
                      valueNotifier: _clienteCreateForm.bairro,
                      validator: _clienteCreateValidator.byField(
                          _clienteCreateForm, "bairro"),
                      onChanged: _clienteCreateForm.setBairro,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: CustomTextFormField(
                            hint: "Rua...",
                            label: "Rua*",
                            type: TextInputType.text,
                            maxLength: 40,
                            rightPadding: 8,
                            hide: false,
                            valueNotifier: _clienteCreateForm.rua,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "endereco"),
                            onChanged: _clienteCreateForm.setRua,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomTextFormField(
                            hint: "Número...",
                            label: "Número*",
                            type: TextInputType.text,
                            leftPadding: 0,
                            maxLength: 6,
                            hide: false,
                            valueNotifier: _clienteCreateForm.numero,
                            validator: _clienteCreateValidator.byField(
                                _clienteCreateForm, "numero"),
                            onChanged: _clienteCreateForm.setNumero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      hint: "Complemento...",
                      label: "Complemento",
                      type: TextInputType.text,
                      maxLength: 100,
                      hide: false,
                      valueNotifier: _clienteCreateForm.complemento,
                      validator: _clienteCreateValidator.byField(
                          _clienteCreateForm, "complemento"),
                      onChanged: _clienteCreateForm.setComplemento,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          children: const [
                            Text(
                              "* - Campos obrigatórios",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "** - Preencha ao menos um destes campos",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                  Navigator.pop(context);
                                } else if (state is ClienteErrorState) {
                                  ErrorEntity error = state.error;

                                  _clienteCreateValidator
                                      .applyBackendError(error);
                                  _clienteFormKey.currentState?.validate();
                                  _clienteCreateValidator.cleanExternalErrors();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "[ERROR] Informação(ões) inválida(s) ao registrar o Cliente.")));
                                }
                              },
                              child: ElevatedButton(
                                onPressed: _registerCliente,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007BFF),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                child: const Text("Adicionar",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
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
    );
  }

  @override
  void dispose() {
    _enderecoBloc.close();
    _clienteBloc.close();
    _debounce?.cancel();
    super.dispose();
  }
}
