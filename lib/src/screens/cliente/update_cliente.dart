import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  List<String> _dropdownValuesNomes = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _clienteUpdateForm.setId(widget.id);
    _clienteBloc = context.read<ClienteBloc>();
    _clienteBloc.add(ClienteSearchOneEvent(id: widget.id)); // A busca do cliente
  }

  void _onNomeChanged(String nome) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchClienteNames(nome));
  }

  void _fetchClienteNames(String nome) async {
    _clienteUpdateForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownValuesNomes.isEmpty) return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
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
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response =
        _clienteUpdateValidator.validate(_clienteUpdateForm);
    return response.isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Atualizar Cliente"),
        centerTitle: true,
      ),
      body: BlocBuilder<ClienteBloc, ClienteState>(
        bloc: _clienteBloc,
        buildWhen: (previousState, state) {
          if (state is ClienteSearchOneSuccessState) {
            _clienteUpdateForm.nome.value = state.cliente.nome!;
            _nomeController.text = _clienteUpdateForm.nome.value;
            _clienteUpdateForm.telefoneCelular.value = (state.cliente.telefoneCelular!.isEmpty
                ? ""
                : Constants.deTransformarMask(state.cliente.telefoneCelular!));
            _clienteUpdateForm.telefoneFixo.value = (state.cliente.telefoneFixo!.isEmpty
                    ? ""
                    : Constants.deTransformarMask(state.cliente.telefoneFixo!));
            _clienteUpdateForm.municipio.value = state.cliente.municipio!;
            _clienteUpdateForm.bairro.value = state.cliente.bairro!;
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return (state is ClienteSearchOneSuccessState)
            ? Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              child: SingleChildScrollView(
                child: Form(
                  key: _clienteFormKey,
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
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
                        onChanged: _onNomeChanged,
                        controller: _nomeController,
                        label: "Nome",
                        maxLength: 40,
                        dropdownValues: _dropdownValuesNomes,
                        validator: _clienteUpdateValidator.byField(
                            _clienteUpdateForm, "nome"),
                      ),
                    ),
                    CustomTextFormField(
                      valueNotifier: _clienteUpdateForm.telefoneCelular,
                      hint: "(99) 99999-9999",
                      label: "Telefone Celular",
                      masks: Constants.maskTelefone,
                      maxLength: 15,
                      type: TextInputType.phone,
                      hide: false,
                      validator: _clienteUpdateValidator.byField(
                          _clienteUpdateForm, "telefoneCelular"),
                      onChanged: _clienteUpdateForm.setTelefoneCelular,
                    ),
                    CustomTextFormField(
                      valueNotifier: _clienteUpdateForm.telefoneFixo,
                      hint: "(99) 99999-9999",
                      label: "Telefone Fixo",
                      masks: Constants.maskTelefone,
                      maxLength: 15,
                      type: TextInputType.phone,
                      hide: false,
                      validator: _clienteUpdateValidator.byField(
                          _clienteUpdateForm, "telefoneFixo"),
                      onChanged: _clienteUpdateForm.setTelefoneFixo,
                    ),
                    BlocListener<EnderecoBloc, EnderecoState>(
                      bloc: _enderecoBloc,
                      listener: (context, state) {
                        if (state is EnderecoSuccessState) {
                          _clienteUpdateForm.setRua(state.rua);
                          _clienteUpdateForm.setNumero(state.numero);
                          _clienteUpdateForm
                              .setComplemento(state.complemento);
                        }
                      },
                      child: Column(
                        children: [
                          CustomTextFormField(
                            valueNotifier: _clienteUpdateForm.rua,
                            hint: "Rua...",
                            label: "Rua",
                            maxLength: 255,
                            hide: true,
                            type: TextInputType.text,
                            validator: _clienteUpdateValidator.byField(
                                _clienteUpdateForm, "rua"),
                            onChanged: _clienteUpdateForm.setRua,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextFormField(
                                  valueNotifier: _clienteUpdateForm.numero,
                                  hint: "Número",
                                  label: "Número",
                                  maxLength: 10,
                                  hide: false,
                                  type: TextInputType.number,
                                  validator:
                                      _clienteUpdateValidator.byField(
                                          _clienteUpdateForm, "numero"),
                                  onChanged: _clienteUpdateForm.setNumero,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: CustomTextFormField(
                                  valueNotifier:
                                      _clienteUpdateForm.complemento,
                                  hint: "Complemento...",
                                  label: "Complemento",
                                  maxLength: 255,
                                  hide: false,
                                  type: TextInputType.text,
                                  validator:
                                      _clienteUpdateValidator.byField(
                                          _clienteUpdateForm,
                                          "complemento"),
                                  onChanged:
                                      _clienteUpdateForm.setComplemento,
                                ),
                              ),
                            ],
                          ),
                          CustomDropdownField(
                            label: "Município",
                            dropdownValues: Constants.municipios,
                            valueNotifier: _clienteUpdateForm.municipio,
                            validator: _clienteUpdateValidator.byField(
                                _clienteUpdateForm, "municipio"),
                            onChanged: _clienteUpdateForm.setMunicipio,
                          ),
                          CustomTextFormField(
                            valueNotifier: _clienteUpdateForm.bairro,
                            hint: "Bairro...",
                            label: "Bairro",
                            maxLength: 255,
                            hide: true,
                            type: TextInputType.text,
                            validator: _clienteUpdateValidator.byField(
                                _clienteUpdateForm, "bairro"),
                            onChanged: _clienteUpdateForm.setBairro,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 750),
                      child: ElevatedButton(
                        onPressed: _updateCliente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Atualizar Cliente",
                          style:
                              TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
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
