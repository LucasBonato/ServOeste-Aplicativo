import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';

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
    if (_debounce?.isActive?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 150), () => _fetchClienteNames(nome));
  }

  void _fetchClienteNames(String nome) async {
    _clienteCreateForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownValuesNomes.isEmpty) return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
  }

  void _fetchInformationAboutCep(String? cep) async {
    if(cep?.length != 9) return;
    _clienteCreateForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response = _clienteCreateValidator.validate(_clienteCreateForm);
    return response.isValid;
  }

  void _registerCliente() {
    if(_isValidForm() == false) {
      return;
    }

    List<String> nomes = _clienteCreateForm.nome.value.split(" ");
    _clienteCreateForm.nome.value = nomes.first;
    String sobrenome = nomes
        .sublist(1)
        .join(" ")
        .trim();

    _clienteBloc.add(ClienteRegisterEvent(cliente: Cliente.fromForm(_clienteCreateForm), sobrenome: sobrenome));
    _clienteCreateForm.nome.value = "${nomes.first} $sobrenome";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, ""),
        ),
        title: const Text("Novo Cliente"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: SingleChildScrollView(
          child: Form(
            key: _clienteFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                BlocListener<ClienteBloc, ClienteState>(
                  bloc: _clienteBloc,
                  listener: (context, state) {
                    if (state is ClienteSearchSuccessState) {
                      List<String> nomes = state.clientes
                          .take(5)
                          .map((cliente) => cliente.nome!)
                          .toList();

                      if(_dropdownValuesNomes != nomes) {
                        _dropdownValuesNomes = nomes;
                        setState(() {});
                      }
                    }
                  },
                  child: CustomSearchDropDown(
                    onChanged: _onNomeChanged,
                    label: "Nome",
                    maxLength: 40,
                    dropdownValues: _dropdownValuesNomes,
                    validator: _clienteCreateValidator.byField(_clienteCreateForm, "nome"),
                  ),
                ),
                CustomTextFormField(
                  valueNotifier: _clienteCreateForm.telefoneCelular,
                  hint: "(99) 99999-9999",
                  label: "Telefone Celular",
                  masks: Constants.maskTelefone,
                  maxLength: 15,
                  type: TextInputType.phone,
                  hide: false,
                  validator: _clienteCreateValidator.byField(_clienteCreateForm, "telefoneCelular"),
                  onChanged: _clienteCreateForm.setTelefoneCelular,
                ),  // Telefone Celular
                CustomTextFormField(
                  valueNotifier: _clienteCreateForm.telefoneFixo,
                  hint: "(99) 99999-9999",
                  label: "Telefone Fixo",
                  masks: Constants.maskTelefone,
                  maxLength: 15,
                  type: TextInputType.phone,
                  hide: false,
                  validator: _clienteCreateValidator.byField(_clienteCreateForm, "telefoneFixo"),
                  onChanged: _clienteCreateForm.setTelefoneFixo,
                ),  // Telefone Fixo
                BlocListener<EnderecoBloc, EnderecoState>(
                  bloc: _enderecoBloc,
                  listener: (context, state) {
                    if (state is EnderecoSuccessState) {
                      _clienteCreateForm.setEndereco(state.endereco!);
                      _clienteCreateForm.setMunicipio(state.municipio!);
                      _clienteCreateForm.setBairro(state.bairro!);
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomTextFormField(
                              valueNotifier: _clienteCreateForm.cep,
                              hint: "00000-000",
                              label: "CEP",
                              hide: true,
                              maxLength: 9,
                              masks: Constants.maskCep,
                              rightPadding: 4,
                              type: TextInputType.number,
                              validator: _clienteCreateValidator.byField(_clienteCreateForm, "cep"),
                              onChanged: _fetchInformationAboutCep,
                            ),
                          ), // CEP
                          Expanded(
                            flex: 8,
                            child: CustomTextFormField(
                              valueNotifier: _clienteCreateForm.endereco,
                              hint: "Rua...",
                              label: "Endereço, Número e Complemento",
                              validator: _clienteCreateValidator.byField(_clienteCreateForm, "endereco"),
                              maxLength: 255,
                              hide: true,
                              type: TextInputType.text,
                              leftPadding: 4,
                              onChanged: _clienteCreateForm.setEndereco,
                            ),
                          ), // Endereço
                        ],
                      ),
                      CustomDropdownField(
                        label: "Município",
                        dropdownValues: Constants.municipios,
                        valueNotifier: _clienteCreateForm.municipio,
                        validator: _clienteCreateValidator.byField(_clienteCreateForm, "municipio"),
                        onChanged: _clienteCreateForm.setMunicipio,
                      ),
                      CustomTextFormField(
                        valueNotifier: _clienteCreateForm.bairro,
                        hint: "Bairro...",
                        label: "Bairro",
                        validator: _clienteCreateValidator.byField(_clienteCreateForm, "bairro"),
                        maxLength: 255,
                        hide: true,
                        type: TextInputType.text,
                        onChanged: _clienteCreateForm.setBairro,
                      ), // Bairro
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 128),
                        child: BlocListener<ClienteBloc, ClienteState>(
                          bloc: _clienteBloc,
                          listener: (context, state) {
                            if (state is ClienteRegisterSuccessState) {
                              Navigator.pop(context);
                            }
                            else if (state is ClienteErrorState) {
                              ErrorEntity error = state.error;

                              _clienteCreateValidator.applyBackendError(error);
                              _clienteFormKey.currentState?.validate();
                              _clienteCreateValidator.cleanExternalErrors();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("[ERROR] Informação(ões) inválida(s) ao registrar o Cliente."))
                              );

                            }
                          },
                          child: ElevatedButton(
                            onPressed: () => _registerCliente(),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                            ),
                            child: const Text("Adicionar"),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ),
          ),
        )
      )
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