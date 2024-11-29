import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';

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
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response = _clienteValidator.validate(_clienteForm);
    return response.isValid;
  }

  void _registerCliente() {
    if (_isValidForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente adicionado com sucesso!')),
      );
      Navigator.pop(context);
    }
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
              ),
              const Text(
                "Voltar",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
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
                    CustomTextFormField(
                      hint: "Nome...",
                      label: "Nome*",
                      type: TextInputType.name,
                      maxLength: 40,
                      hide: false,
                      valueNotifier: _clienteForm.nome,
                      controller: _nomeController,
                      validator:
                          _clienteValidator.byField(_clienteForm, "nome"),
                      onChanged: _clienteForm.setNome,
                    ),
                    const SizedBox(height: 12),
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
                              MaskTextInputFormatter(mask: '(##) ####-####'),
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
                            type: TextInputType.phone,
                            maxLength: 15,
                            hide: false,
                            masks: [
                              MaskTextInputFormatter(mask: '(##) #####-####'),
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
                            validator:
                                _clienteValidator.byField(_clienteForm, "cep"),
                            onChanged: _clienteForm.setCep,
                          ),
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            hint: "Município...",
                            label: "Município*",
                            type: TextInputType.text,
                            maxLength: 40,
                            hide: false,
                            valueNotifier: _clienteForm.municipio,
                            controller: _municipioController,
                            validator: _clienteValidator.byField(
                                _clienteForm, "municipio"),
                            onChanged: _clienteForm.setMunicipio,
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
                          flex: 3,
                          child: CustomTextFormField(
                            hint: "Rua...",
                            label: "Rua*",
                            type: TextInputType.text,
                            maxLength: 40,
                            hide: false,
                            valueNotifier: _clienteForm.rua,
                            controller: _ruaController,
                            validator:
                                _clienteValidator.byField(_clienteForm, "rua"),
                            onChanged: _clienteForm.setRua,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomTextFormField(
                            hint: "Número...",
                            label: "Número*",
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
                      maxLength: 100,
                      hide: false,
                      valueNotifier: _clienteForm.complemento,
                      controller: _complementoController,
                      onChanged: _clienteForm.setComplemento,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
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
                      child: ElevatedButton(
                        onPressed: _registerCliente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Adicionar Cliente",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
    _telefoneFixoController.dispose();
    _telefoneCelularController.dispose();
    _cepController.dispose();
    _municipioController.dispose();
    _bairroController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }
}
