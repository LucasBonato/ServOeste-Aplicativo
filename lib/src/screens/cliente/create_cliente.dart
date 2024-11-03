import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_create_form.dart';
import '../../shared/constants.dart';
import '../../components/dropdown_field.dart';
import '../../models/cliente/cliente.dart';

class CreateCliente extends StatefulWidget {
  const CreateCliente({super.key});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {
  final EnderecoBloc _enderecoBloc = EnderecoBloc();
  final ClienteBloc _clienteBloc = ClienteBloc();
  final ClienteCreateForm clienteCreateForm = ClienteCreateForm();
  final ClienteCreateValidator clienteCreateValidator = ClienteCreateValidator();
  final GlobalKey<FormState> clienteFormKey = GlobalKey<FormState>();
  final List<MaskTextInputFormatter> maskCep = [
    MaskTextInputFormatter(
      mask: '#####-###',
      filter: { "#": RegExp(r'[0-9]') },
    )
  ];
  final List<MaskTextInputFormatter> maskTelefone = [
    MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
    )
  ];
  late TextEditingController nomeController;
  List<String> _dropdownValuesNomes = [];

  String _errorMessage = "",
      _sobrenome = "";
  bool
    validationNome = false,
    validationTelefoneCelular = false,
    validationTelefoneFixo = false,
    validationCep = false,
    validationEndereco = false,
    validationBairro = false,
    validationMunicipio = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  void setError(int erro, String errorMessage){
    setErrorNome(String errorMessage){
      _errorMessage = errorMessage;
      validationNome = true;
    }
    setErrorTelefoneCelular(String errorMessage){
      _errorMessage = errorMessage;
      validationTelefoneCelular = true;
    }
    setErrorTelefoneFixo(String errorMessage){
      _errorMessage = errorMessage;
      validationTelefoneFixo = true;
    }
    setErrorTelefones(String errorMessage){
      setErrorTelefoneCelular(errorMessage);
      setErrorTelefoneFixo(errorMessage);
    }
    setErrorCep(String errorMessage){
      _errorMessage = errorMessage;
      validationCep = true;
    }
    setErrorEndereco(String errorMessage){
      _errorMessage = errorMessage;
      validationEndereco = true;
    }
    setErrorBairro(String errorMessage){
      _errorMessage = errorMessage;
      validationBairro = true;
    }
    setErrorMunicipio(String errorMessage){
      _errorMessage = errorMessage;
      validationMunicipio = true;
    }
    setState(() {
      validationNome = false;
      validationTelefoneCelular = false;
      validationTelefoneFixo = false;
      validationCep = false;
      validationEndereco = false;
      validationBairro = false;
      validationMunicipio = false;
      _errorMessage = "";

      switch(erro){
        case 1: setErrorNome(errorMessage); break;
        case 2: setErrorTelefoneCelular(errorMessage); break;
        case 3: setErrorTelefoneFixo(errorMessage); break;
        case 4: setErrorTelefones(errorMessage); break;
        case 5: setErrorCep(errorMessage); break;
        case 6: setErrorEndereco(errorMessage); break;
        case 7: setErrorBairro(errorMessage); break;
        case 8: setErrorMunicipio(errorMessage); break;
      }
    });
  }

  void fetchClienteNames(String nome) async{
    if(nome == "") return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
  }

  void fetchInformationAboutCep(String? cep) async {
    if(cep?.length != 9) return;
    clienteCreateForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  bool isValidForm() {
    clienteFormKey.currentState?.validate();
    final ValidationResult response = clienteCreateValidator.validate(clienteCreateForm);
    return response.isValid;
  }

  void registerCliente() {
    List<String> nomes = clienteCreateForm.nome.value.split(" ");
    clienteCreateForm.nome.value = nomes.first;
    _sobrenome = nomes
        .sublist(1)
        .join(" ")
        .trim();

    _clienteBloc.add(ClienteRegisterEvent(cliente: Cliente.fromCreateForm(clienteCreateForm), sobrenome: _sobrenome));
    // ClienteService clienteService = ClienteService();
    // Cliente cliente = includeData();
    // dynamic body = await clienteService.create(cliente, _sobrenome);
    //
    // if(body == null && context.mounted) {
    //   Navigator.pop(context);
    //   return;
    // }
    //
    // setError(body["idError"], body["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Novo Cliente"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: SingleChildScrollView(
          child: Form(
            key: clienteFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                BlocListener<ClienteBloc, ClienteState>(
                  bloc: _clienteBloc,
                  listener: (context, state) {
                    if (state is ClienteSuccessState) {
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
                    onChanged: fetchClienteNames,
                    label: "Nome",
                    controller: nomeController,
                    maxLength: 40,
                    dropdownValues: _dropdownValuesNomes,
                    errorMessage: _errorMessage,
                    validation: validationNome,
                  ),
                ),
                CustomTextFormField(
                  valueNotifier: clienteCreateForm.telefoneCelular,
                  hint: "(99) 99999-9999",
                  label: "Telefone Celular",
                  masks: maskTelefone,
                  maxLength: 15,
                  type: TextInputType.phone,
                  hide: false,
                  onChanged: clienteCreateForm.setTelefoneCelular,
                ),  // Telefone Celular
                CustomTextFormField(
                  valueNotifier: clienteCreateForm.telefoneFixo,
                  hint: "(99) 99999-9999",
                  label: "Telefone Fixo",
                  masks: maskTelefone,
                  maxLength: 15,
                  type: TextInputType.phone,
                  hide: false,
                  onChanged: clienteCreateForm.setTelefoneFixo,
                ),  // Telefone Fixo
                BlocListener<EnderecoBloc, EnderecoState>(
                  bloc: _enderecoBloc,
                  listener: (context, state) {
                    if (state is EnderecoSuccessState) {
                      clienteCreateForm.setEndereco(state.endereco!);
                      clienteCreateForm.setMunicipio(state.municipio!);
                      clienteCreateForm.setBairro(state.bairro!);
                    } else if (state is EnderecoErrorState) {
                      Logger().e(state.error.errorMessage);
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomTextFormField(
                              valueNotifier: clienteCreateForm.cep,
                              hint: "00000-000",
                              label: "CEP",
                              hide: true,
                              maxLength: 9,
                              masks: maskCep,
                              rightPadding: 4,
                              type: TextInputType.number,
                              validator: clienteCreateValidator.byField(clienteCreateForm, "cep"),
                              onChanged: fetchInformationAboutCep,
                            ),
                          ), // CEP
                          Expanded(
                            flex: 8,
                            child: CustomTextFormField(
                              valueNotifier: clienteCreateForm.endereco,
                              hint: "Rua...",
                              label: "Endereço, Número e Complemento",
                              validator: clienteCreateValidator.byField(clienteCreateForm, "endereco"),
                              maxLength: 255,
                              hide: true,
                              type: TextInputType.text,
                              leftPadding: 4,
                              onChanged: clienteCreateForm.setEndereco,
                            ),
                          ), // Endereço
                        ],
                      ),
                      CustomDropdownField(
                        label: "Município",
                        dropdownValues: Constants.municipios,
                        valueNotifier: clienteCreateForm.municipio,
                      ),
                      CustomTextFormField(
                        valueNotifier: clienteCreateForm.bairro,
                        hint: "Bairro...",
                        label: "Bairro",
                        validator: clienteCreateValidator.byField(clienteCreateForm, "bairro"),
                        maxLength: 255,
                        hide: true,
                        type: TextInputType.text,
                        onChanged: clienteCreateForm.setBairro,
                      ), // Bairro
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 128),
                        child: ElevatedButton(
                          onPressed: () => Logger().w(isValidForm() ? "Válido" : "Inválido"),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                          ),
                          child: const Text("Adicionar"),
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
}