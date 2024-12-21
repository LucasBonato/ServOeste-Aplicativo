import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/src/util/formatters.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class UpdateCliente extends StatefulWidget {
  final int id;

  const UpdateCliente({super.key, required this.id});

  @override
  State<UpdateCliente> createState() => _UpdateClienteState();
}

class _UpdateClienteState extends State<UpdateCliente> {
  late final ClienteBloc _clienteBloc;
  final EnderecoBloc _enderecoBloc = EnderecoBloc();
  final ClienteForm _clienteUpdateForm = ClienteForm();
  final ClienteValidator _clienteUpdateValidator = ClienteValidator();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  late final TextEditingController _municipioController;
  List<String> _dropdownValuesNomes = [];

  @override
  void initState() {
    super.initState();
    _clienteUpdateForm.setId(widget.id);
    _clienteBloc = context.read<ClienteBloc>();
    _clienteBloc.add(ClienteSearchOneEvent(id: widget.id));
  }

  void _fetchInformationAboutCep(String? cep) async {
    if (cep?.length != 9) return;
    _clienteUpdateForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  void _updateCliente() {
    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _clienteUpdateForm.nome.value.split(" ");
    _clienteUpdateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _clienteBloc.add(ClienteUpdateEvent(
        cliente: Cliente.fromForm(_clienteUpdateForm), sobrenome: sobrenome));
    _clienteUpdateForm.nome.value = "${nomes.first} $sobrenome";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente atualizado com sucesso!')),
    );
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response =
        _clienteUpdateValidator.validate(_clienteUpdateForm);
    return response.isValid;
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
      body: BlocBuilder<ClienteBloc, ClienteState>(
        bloc: _clienteBloc,
        buildWhen: (previousState, state) {
          if (state is ClienteSearchOneSuccessState) {
            _clienteUpdateForm.nome.value = state.cliente.nome!;
            _nomeController.text = _clienteUpdateForm.nome.value;
            _clienteUpdateForm.telefoneFixo.value = (state
                    .cliente.telefoneFixo!.isEmpty
                ? ""
                : Formatters.applyTelefoneMask(state.cliente.telefoneFixo!));
            _clienteUpdateForm.telefoneCelular.value = (state
                    .cliente.telefoneCelular!.isEmpty
                ? ""
                : Formatters.applyCelularMask(state.cliente.telefoneCelular!));
            _clienteUpdateForm.municipio.value = state.cliente.municipio!;
            _clienteUpdateForm.bairro.value = state.cliente.bairro!;

            String endereco = state.cliente.endereco ?? "";
            List<String> partes = endereco.split(',');

            String rua = partes[0].trim();
            String numero = partes.length > 1 ? partes[1].trim() : '';
            String complemento =
                partes.length > 2 ? partes.sublist(2).join(',').trim() : '';

            _clienteUpdateForm.rua.value = rua;
            _clienteUpdateForm.numero.value = numero;
            _clienteUpdateForm.complemento.value = complemento;

            return true;
          }
          return false;
        },
        builder: (context, state) {
          return (state is ClienteSearchOneSuccessState)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _clienteFormKey,
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
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
                              child: CustomTextFormField(
                                hint: "Nome...",
                                label: "Nome*",
                                type: TextInputType.name,
                                maxLength: 40,
                                rightPadding: 8,
                                hide: false,
                                valueNotifier: _clienteUpdateForm.nome,
                                validator: _clienteUpdateValidator.byField(
                                    _clienteUpdateForm,
                                    ErrorCodeKey.nomeESobrenome.name),
                                onChanged: _clienteUpdateForm.setNome,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    valueNotifier:
                                        _clienteUpdateForm.telefoneFixo,
                                    hint: "(99) 9999-9999",
                                    label: "Telefone Fixo**",
                                    masks: InputMasks.maskTelefoneFixo,
                                    rightPadding: 8,
                                    maxLength: 14,
                                    type: TextInputType.phone,
                                    hide: true,
                                    validator: _clienteUpdateValidator.byField(
                                        _clienteUpdateForm,
                                        ErrorCodeKey.telefones.name),
                                    onChanged:
                                        _clienteUpdateForm.setTelefoneFixo,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextFormField(
                                    valueNotifier:
                                        _clienteUpdateForm.telefoneCelular,
                                    hint: "(99) 99999-9999",
                                    label: "Telefone Celular**",
                                    masks: InputMasks.maskCelular,
                                    leftPadding: 0,
                                    maxLength: 15,
                                    hide: true,
                                    type: TextInputType.phone,
                                    validator: _clienteUpdateValidator.byField(
                                        _clienteUpdateForm,
                                        ErrorCodeKey.telefones.name),
                                    onChanged:
                                        _clienteUpdateForm.setTelefoneCelular,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                      BlocListener<EnderecoBloc, EnderecoState>(
                                    bloc: _enderecoBloc,
                                    listener: (context, state) {
                                      if (state is EnderecoSuccessState) {
                                        _clienteUpdateForm
                                            .setBairro(state.bairro);
                                        _clienteUpdateForm.setRua(state.rua);
                                        _clienteUpdateForm
                                            .setMunicipio(state.municipio);
                                        _municipioController.text =
                                            state.municipio;
                                      }
                                    },
                                    child: CustomTextFormField(
                                      hint: "00000-000",
                                      label: "CEP",
                                      type: TextInputType.streetAddress,
                                      rightPadding: 8,
                                      maxLength: 9,
                                      hide: true,
                                      masks: InputMasks.maskCep,
                                      valueNotifier: _clienteUpdateForm.cep,
                                      validator:
                                          _clienteUpdateValidator.byField(
                                              _clienteUpdateForm,
                                              ErrorCodeKey.cep.name),
                                      onChanged: _fetchInformationAboutCep,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: CustomSearchDropDown(
                                    label: "Município*",
                                    dropdownValues: Constants.municipios,
                                    leftPadding: 0,
                                    valueNotifier: _clienteUpdateForm.municipio,
                                    validator: _clienteUpdateValidator.byField(
                                        _clienteUpdateForm,
                                        ErrorCodeKey.municipio.name),
                                    onChanged: _clienteUpdateForm.setMunicipio,
                                  ),
                                ),
                              ],
                            ),
                            CustomTextFormField(
                              valueNotifier: _clienteUpdateForm.bairro,
                              hint: "Bairro...",
                              label: "Bairro*",
                              maxLength: 255,
                              hide: true,
                              type: TextInputType.text,
                              validator: _clienteUpdateValidator.byField(
                                  _clienteUpdateForm, ErrorCodeKey.bairro.name),
                              onChanged: _clienteUpdateForm.setBairro,
                            ),
                            BlocListener<EnderecoBloc, EnderecoState>(
                              bloc: _enderecoBloc,
                              listener: (context, state) {
                                if (state is EnderecoSuccessState) {
                                  _clienteUpdateForm.rua.value = state.rua;
                                  _clienteUpdateForm.numero.value =
                                      state.numero;
                                  _clienteUpdateForm.complemento.value =
                                      state.complemento;
                                }
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextFormField(
                                          valueNotifier: _clienteUpdateForm.rua,
                                          hint: "Rua...",
                                          label: "Rua*",
                                          maxLength: 255,
                                          rightPadding: 8,
                                          hide: true,
                                          type: TextInputType.text,
                                          validator:
                                              _clienteUpdateValidator.byField(
                                                  _clienteUpdateForm,
                                                  ErrorCodeKey.rua.name),
                                          onChanged: _clienteUpdateForm.setRua,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: CustomTextFormField(
                                          valueNotifier:
                                              _clienteUpdateForm.numero,
                                          hint: "Número...",
                                          label: "Número*",
                                          maxLength: 10,
                                          leftPadding: 0,
                                          hide: true,
                                          type: TextInputType.number,
                                          validator:
                                              _clienteUpdateValidator.byField(
                                                  _clienteUpdateForm,
                                                  ErrorCodeKey.numero.name),
                                          onChanged:
                                              _clienteUpdateForm.setNumero,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomTextFormField(
                                    valueNotifier:
                                        _clienteUpdateForm.complemento,
                                    hint: "Complemento...",
                                    label: "Complemento",
                                    maxLength: 255,
                                    hide: false,
                                    type: TextInputType.text,
                                    validator: _clienteUpdateValidator.byField(
                                        _clienteUpdateForm,
                                        ErrorCodeKey.complemento.name),
                                    onChanged:
                                        _clienteUpdateForm.setComplemento,
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: BuildFieldLabels()),
                            SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 750),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BlocListener<ClienteBloc, ClienteState>(
                                    bloc: _clienteBloc,
                                    listener: (context, state) {
                                      if (state is ClienteUpdateSuccessState) {
                                        _handleBackNavigation();
                                      } else if (state is ClienteErrorState) {
                                        ErrorEntity error = state.error;

                                        _clienteUpdateValidator
                                            .applyBackendError(error);
                                        _clienteFormKey.currentState
                                            ?.validate();
                                        _clienteUpdateValidator
                                            .cleanExternalErrors();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "[ERROR] Informação(ões) inválida(s) ao Atualizar o Cliente.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: ElevatedButton(
                                      onPressed: _updateCliente,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF007BFF),
                                        minimumSize:
                                            const Size(double.infinity, 48),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Atualizar Cliente",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    _enderecoBloc.close();
    _nomeController.dispose();
    super.dispose();
  }
}
