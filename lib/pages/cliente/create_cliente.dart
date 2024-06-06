import 'package:flutter/material.dart';
import 'package:serv_oeste/service/cliente_service.dart';

import '../../components/mask_field.dart';
import '../../models/cliente.dart';

class CreateCliente extends StatefulWidget {
  final VoidCallback onIconPressed;

  const CreateCliente({super.key, required this.onIconPressed});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {

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
    List<String> charsDeTelefone = telefone.split("");
    String telefoneFormatado = "";
    for(int i = 0; i < charsDeTelefone.length; i++){
      if(i == 0) continue;
      if(i == 3) continue;
      if(i == 4) continue;
      if(i == 10) continue;
      telefoneFormatado += charsDeTelefone[i];
    }
    return telefoneFormatado;
  }

  Future<void> adicionarCliente() async{
    ClienteService clienteService = ClienteService();
    Cliente cliente = includeData();
    dynamic body = await clienteService.create(cliente, _sobrenome);

    if(body == null) {
      widget.onIconPressed();
      return;
    }

    setError(body["idError"], body["message"]);
  }

  void getInformationsAboutCep(cep) {

  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onIconPressed,
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
                    Column(
                      children: [
                        CustomMaskField(
                          hint: "Nome...",
                          label: "Nome",
                          mask: null,
                          errorMessage: _errorMessage,
                          maxLength: 40,
                          controller: nomeController,
                          validation: validationNome,
                          type: TextInputType.name,
                        ),  // Nome
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
                                onChanged: (cep) => getInformationsAboutCep(cep),
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
                                  type: TextInputType.text
                              ),
                            ),  // Endereço
                          ],
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
                        CustomMaskField(
                          hint: "Município...",
                          label: "Município",
                          mask: null,
                          errorMessage: _errorMessage,
                          maxLength: 255,
                          hide: true,
                          controller: municipioController,
                          validation: validationMunicipio,
                          type: TextInputType.text
                        ),  // Município
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: TextButton(
                              onPressed: adicionarCliente,
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
