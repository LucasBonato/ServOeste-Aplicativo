import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';

class CreateCliente extends StatefulWidget {
  const CreateCliente({super.key});

  @override
  State<CreateCliente> createState() => _CreateClienteState();
}

class _CreateClienteState extends State<CreateCliente> {
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final ClienteValidator _clienteValidator = ClienteValidator();
  final ClienteForm _clienteForm = ClienteForm();

  late TextEditingController _nomeController,
      _telefoneFixoController,
      _telefoneCelularController,
      _cepController,
      _municipioController,
      _bairroController,
      _ruaController,
      _numeroController,
      _complementoController;

  final EnderecoBloc _enderecoBloc = EnderecoBloc();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneFixoController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _cepController = TextEditingController();
    _municipioController = TextEditingController();
    _bairroController = TextEditingController();
    _ruaController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();

    _cepController.addListener(_onCepChanged);
  }

  void _onCepChanged() {
    final cep = _cepController.text;
    if (cep.length == 9) {
      _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep));
    }
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response = _clienteValidator.validate(_clienteForm);
    return response.isValid;
  }

  void _registerCliente() {
    if (_isValidForm()) {
      final cliente = Cliente(
        nome: _clienteForm.nome.value,
        telefoneFixo: _clienteForm.telefoneFixo.value,
        telefoneCelular: _clienteForm.telefoneCelular.value,
        cep: _clienteForm.cep.value,
        municipio: _clienteForm.municipio.value,
        bairro: _clienteForm.bairro.value,
        rua: _clienteForm.rua.value,
        numero: _clienteForm.numero.value,
        complemento: _clienteForm.complemento.value,
      );

      context.read<ClienteBloc>().add(
            ClienteRegisterEvent(cliente: cliente, sobrenome: "Sobrenome"),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _enderecoBloc,
      child: BlocListener<EnderecoBloc, EnderecoState>(
        listener: (context, state) {
          if (state is EnderecoLoadingState) {
            print("Buscando endereço...");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Buscando endereço...')),
            );
          } else if (state is EnderecoSuccessState) {
            print(
                "Endereço encontrado: ${state.rua}, ${state.bairro}, ${state.municipio}");
            _ruaController.text = state.rua;
            _bairroController.text = state.bairro;
            _municipioController.text = state.municipio;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          } else if (state is EnderecoErrorState) {
            print("Erro ao buscar endereço: ${state.errorMessage}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F4FF),
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context, "Back"),
                  ),
                  const Text(
                    "Voltar",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFCFDFDFF),
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
                        CustomSearchDropDown(
                          label: "Nome*",
                          dropdownValues: const [
                            "João Silva",
                            "Maria Oliveira",
                            "Carlos Souza"
                          ],
                          controller: _nomeController,
                          onChanged: (value) => _clienteForm.setNome(value),
                          validator:
                              _clienteValidator.byField(_clienteForm, "nome"),
                          onSaved: (value) => _clienteForm.setNome(value ?? ""),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                hint: "(99) 9999-9999",
                                label: "Telefone Fixo**",
                                type: TextInputType.phone,
                                maxLength: 14,
                                hide: false,
                                masks: [
                                  MaskTextInputFormatter(
                                      mask: '(##) ####-####'),
                                ],
                                valueNotifier: _clienteForm.telefoneFixo,
                                controller: _telefoneFixoController,
                                validator: _clienteValidator.byField(
                                    _clienteForm, "telefoneFixo"),
                                onChanged: _clienteForm.setTelefoneFixo,
                              ),
                            ),
                            Expanded(
                              child: CustomTextFormField(
                                hint: "(99) 99999-9999",
                                label: "Telefone Celular**",
                                leftPadding: 0,
                                type: TextInputType.phone,
                                maxLength: 15,
                                hide: false,
                                masks: [
                                  MaskTextInputFormatter(
                                      mask: '(##) #####-####'),
                                ],
                                valueNotifier: _clienteForm.telefoneCelular,
                                controller: _telefoneCelularController,
                                validator: _clienteValidator.byField(
                                    _clienteForm, "telefoneCelular"),
                                onChanged: _clienteForm.setTelefoneCelular,
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
                                maxLength: 9,
                                hide: false,
                                masks: [
                                  MaskTextInputFormatter(mask: '#####-###'),
                                ],
                                valueNotifier: _clienteForm.cep,
                                controller: _cepController,
                                validator: _clienteValidator.byField(
                                    _clienteForm, "cep"),
                                onChanged: _clienteForm.setCep,
                              ),
                            ),
                            Expanded(
                              child: CustomSearchDropDown(
                                label: "Município*",
                                dropdownValues: const [
                                  "Osasco",
                                  "Carapicuíba",
                                  "Barueri",
                                  "Cotia",
                                  "São Paulo",
                                  "Itapevi",
                                ],
                                controller: _municipioController,
                                leftPadding: 0,
                                onChanged: (value) =>
                                    _clienteForm.setMunicipio(value),
                                validator: _clienteValidator.byField(
                                    _clienteForm, "municipio"),
                                onSaved: (value) =>
                                    _clienteForm.setMunicipio(value ?? ""),
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
                          hide: false,
                          valueNotifier: _clienteForm.bairro,
                          controller: _bairroController,
                          validator:
                              _clienteValidator.byField(_clienteForm, "bairro"),
                          onChanged: _clienteForm.setBairro,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextFormField(
                                hint: "Rua...",
                                label: "Rua*",
                                type: TextInputType.text,
                                maxLength: 40,
                                hide: false,
                                valueNotifier: _clienteForm.rua,
                                controller: _ruaController,
                                validator: _clienteValidator.byField(
                                    _clienteForm, "rua"),
                                onChanged: _clienteForm.setRua,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CustomTextFormField(
                                hint: "Número...",
                                label: "Número*",
                                leftPadding: 0,
                                type: TextInputType.text,
                                maxLength: 6,
                                hide: false,
                                valueNotifier: _clienteForm.numero,
                                controller: _numeroController,
                                validator: _clienteValidator.byField(
                                    _clienteForm, "numero"),
                                onChanged: _clienteForm.setNumero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          hint: "Complemento...",
                          label: "Complemento",
                          type: TextInputType.text,
                          maxLength: 30,
                          hide: false,
                          valueNotifier: _clienteForm.complemento,
                          controller: _complementoController,
                          validator: _clienteValidator.byField(
                              _clienteForm, "complemento"),
                          onChanged: _clienteForm.setComplemento,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _registerCliente,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "Adicionar Cliente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
