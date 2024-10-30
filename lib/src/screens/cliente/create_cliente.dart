import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import '../../shared/constants.dart';
import '../../components/dropdown_field.dart';
import '../../components/mask_field.dart';
import '../../models/cliente/cliente.dart';

class CreateCliente extends StatefulWidget {
  const CreateCliente({super.key});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {
  final EnderecoBloc _enderecoBloc = EnderecoBloc();
  final List<String> _dropdownValuesNomes = [];
  late TextEditingController nomeController,
      telefoneFixoController,
      telefoneCelularController,
      cepController,
      enderecoController,
      bairroController,
      municipioController;
  String _errorMessage = "",
      _telefoneCelular = "",
      _telefoneFixo = "",
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
    telefoneFixoController = TextEditingController();
    telefoneCelularController = TextEditingController();
    cepController = TextEditingController();
    enderecoController = TextEditingController();
    bairroController = TextEditingController();
    municipioController = TextEditingController();
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneFixoController.dispose();
    telefoneCelularController.dispose();
    cepController.dispose();
    enderecoController.dispose();
    bairroController.dispose();
    municipioController.dispose();
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

  Cliente includeData() {
    List<String> nomes = nomeController.text.split(" ");
    String nome = nomes.first;
    String sobrenome = "";
    for(int i = 1; i < nomes.length; i++){
      sobrenome += "${nomes[i]} ";
    }
    _sobrenome = sobrenome.trim();

    _telefoneCelular = transformarMask(telefoneCelularController.text);
    _telefoneFixo = transformarMask(telefoneFixoController.text);

    return Cliente(
      nome: nome,
      telefoneCelular: _telefoneCelular,
      telefoneFixo: _telefoneFixo,
      endereco: enderecoController.text,
      bairro: bairroController.text,
      municipio: municipioController.text
    );
  }

  String transformarMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
  }

  void adicionarCliente(BuildContext context) async{
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

  void getInformationsAboutCep(String? cep) async {
    if(cep?.length != 9) return;
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
    setError(5, "Endereço não\n encontrado");
  }

  void getNomesClientes(String nome) async{
    // List<Cliente>? clientes = await ClienteService().getByNome(nome);
    // if(clientes == null) return;
    // List<String> nomes = [];
    // for (int i = 0; i < clientes.length && i < 5; i++) {
    //   nomes.add(clientes[i].nome!);
    // }
    // if(_dropdownValuesNomes != nomes) {
    //   setState(() {
    //     _dropdownValuesNomes = nomes;
    //   });
    // }
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomSearchDropDown(
                onChanged: (nome) => getNomesClientes(nome),
                label: "Nome",
                controller: nomeController,
                maxLength: 40,
                dropdownValues: _dropdownValuesNomes,
                errorMessage: _errorMessage,
                validation: validationNome
              ),
              CustomMaskField(
                hint: "(99) 99999-9999",
                label: "Telefone Celular",
                mask: "(##) #####-####",
                errorMessage: _errorMessage,
                maxLength: 15,
                controller: telefoneCelularController,
                validation: validationTelefoneCelular,
                type: TextInputType.phone,
              ),  // Telefone Celular
              CustomMaskField(
                hint: "(99) 99999-9999",
                label: "Telefone Fixo",
                mask: "(##) #####-####",
                errorMessage: _errorMessage,
                maxLength: 15,
                controller: telefoneFixoController,
                validation: validationTelefoneFixo,
                type: TextInputType.phone,
              ),  // Telefone Fixo
              BlocBuilder<EnderecoBloc, EnderecoState>(
                bloc: _enderecoBloc,
                builder: (context, state) {
                  if (state is EnderecoInitialState || state is EnderecoLoadingState) {
                    return Column(
                      children: [
                        Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomMaskField(
                              hint: "00000-000",
                              label: "CEP",
                              mask: "#####-###",
                              errorMessage: _errorMessage,
                              maxLength: 9,
                              hide: true,
                              controller: cepController,
                              validation: validationCep,
                              type: TextInputType.number,
                              rightPadding: 4,
                              onChanged: getInformationsAboutCep,
                            ),
                          ),  // CEP
                          Expanded(
                            flex: 8,
                            child: CustomMaskField(
                              hint: "Rua...",
                              label: "Endereço, Número e Complemento",
                              mask: null,
                              errorMessage: _errorMessage,
                              maxLength: 255,
                              hide: true,
                              controller: enderecoController,
                              validation: validationEndereco,
                              type: TextInputType.text,
                              leftPadding: 4,
                            ),
                          ),  // Endereço
                        ],
                      ),
                      CustomDropdownField(
                        label: "Município",
                        dropdownValues: Constants.municipios,
                        controller: municipioController
                      ),
                      CustomMaskField(
                        hint: "Bairro...",
                        label: "Bairro",
                        mask: null,
                        errorMessage: _errorMessage,
                        maxLength: 255,
                        hide: true,
                        controller: bairroController,
                        validation: validationBairro,
                        type: TextInputType.text
                      ),  // Bairro
                      ],
                    );
                  }
                  else if (state is EnderecoSuccessState) {
                    enderecoController.text = state.endereco!;                    enderecoController.text = state.endereco!;
                    municipioController.text = state.endereco!;
                    enderecoController.text = state.endereco!;

                    return Column(
                      children: [
                        Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomMaskField(
                              hint: "00000-000",
                              label: "CEP",
                              mask: "#####-###",
                              errorMessage: _errorMessage,
                              maxLength: 9,
                              hide: true,
                              controller: cepController,
                              validation: validationCep,
                              type: TextInputType.number,
                              rightPadding: 4,
                              onChanged: getInformationsAboutCep,
                            ),
                          ),  // CEP
                          Expanded(
                            flex: 8,
                            child: CustomMaskField(
                              hint: "Rua...",
                              label: "Endereço, Número e Complemento",
                              mask: null,
                              errorMessage: _errorMessage,
                              maxLength: 255,
                              hide: true,
                              controller: enderecoController,
                              validation: validationEndereco,
                              type: TextInputType.text,
                              leftPadding: 4,
                            ),
                          ),  // Endereço
                        ],
                      ),
                      CustomDropdownField(
                        label: "Município",
                        dropdownValues: Constants.municipios,
                        controller: municipioController
                      ),
                      CustomMaskField(
                        hint: "Bairro...",
                        label: "Bairro",
                        mask: null,
                        errorMessage: _errorMessage,
                        maxLength: 255,
                        hide: true,
                        controller: bairroController,
                        validation: validationBairro,
                        type: TextInputType.text
                      ),  // Bairro
                      ],
                    );
                  }
                },
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
                      child: TextButton(
                        onPressed: () => adicionarCliente(context),
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
        )
      )
    );
  }
}