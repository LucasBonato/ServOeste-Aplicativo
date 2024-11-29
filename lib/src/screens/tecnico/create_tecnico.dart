import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:lucid_validation/lucid_validation.dart';

class CreateTecnico extends StatefulWidget {
  const CreateTecnico({super.key});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  final TecnicoForm _tecnicoCreateForm = TecnicoForm();
  final TecnicoValidator _tecnicoCreateValidator = TecnicoValidator();
  final GlobalKey<FormState> _tecnicoFormKey = GlobalKey<FormState>();

  late TextEditingController _nomeController,
      _telefoneCelularController,
      _telefoneFixoController;

  final Map<String, bool> checkersMap = {
    "Adega": false,
    "Bebedouro": false,
    "Climatizador": false,
    "Cooler": false,
    "Frigobar": false,
    "Geladeira": false,
    "Lava Louça": false,
    "Lava Roupa": false,
    "Microondas": false,
    "Purificador": false,
    "Secadora": false,
    "Outros": false,
  };

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _telefoneFixoController = TextEditingController();
  }

  Widget gridCheckersMap() {
    return FormField(
      validator:
          _tecnicoCreateValidator.byField(_tecnicoCreateForm, "conhecimentos"),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 12,
              childAspectRatio: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: checkersMap.keys.map((label) {
                return Row(
                  children: [
                    Checkbox(
                      value: checkersMap[label] ?? false,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          checkersMap[label] = value ?? false;
                        });
                        field.reset();
                      },
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (field.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  bool _isValidForm() {
    _tecnicoFormKey.currentState?.validate();
    final ValidationResult response =
        _tecnicoCreateValidator.validate(_tecnicoCreateForm);
    return response.isValid;
  }

  void _registerTecnico() {
    checkersMap.forEach((label, isChecked) {
      int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
      if (isChecked) {
        _tecnicoCreateForm.addConhecimentos(idConhecimento);
      } else {
        _tecnicoCreateForm.removeConhecimentos(idConhecimento);
      }
    });
    _tecnicoCreateValidator
        .setConhecimentos(_tecnicoCreateForm.conhecimentos.value);

    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoCreateForm.nome.value.split(" ");
    _tecnicoCreateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _tecnicoBloc.add(TecnicoRegisterEvent(
        tecnico: Tecnico.fromForm(_tecnicoCreateForm), sobrenome: sobrenome));
    _tecnicoCreateForm.nome.value = "${nomes.first} $sobrenome";
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
                key: _tecnicoFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Adicionar Técnico",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomTextFormField(
                        hint: "Nome...",
                        label: "Nome*",
                        type: TextInputType.name,
                        maxLength: 40,
                        hide: false,
                        valueNotifier: _tecnicoCreateForm.nome,
                        controller: _nomeController,
                        validator: _tecnicoCreateValidator.byField(
                            _tecnicoCreateForm, "nome"),
                        onChanged: _tecnicoCreateForm.setNome,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: CustomTextFormField(
                              hint: "(99) 9999-9999",
                              label: "Telefone Fixo**",
                              rightPadding: 0,
                              maxLength: 14,
                              hide: false,
                              masks: [
                                MaskTextInputFormatter(mask: '(##) ####-####'),
                              ],
                              type: TextInputType.phone,
                              valueNotifier: _tecnicoCreateForm.telefoneFixo,
                              controller: _telefoneFixoController,
                              validator: _tecnicoCreateValidator.byField(
                                  _tecnicoCreateForm, "telefoneFixo"),
                              onChanged: _tecnicoCreateForm.setTelefoneFixo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: CustomTextFormField(
                              hint: "(99) 99999-9999",
                              label: "Telefone Celular**",
                              leftPadding: 0,
                              maxLength: 15,
                              hide: false,
                              masks: [
                                MaskTextInputFormatter(mask: '(##) #####-####'),
                              ],
                              type: TextInputType.phone,
                              valueNotifier: _tecnicoCreateForm.telefoneCelular,
                              controller: _telefoneCelularController,
                              validator: _tecnicoCreateValidator.byField(
                                  _tecnicoCreateForm, "telefoneCelular"),
                              onChanged: _tecnicoCreateForm.setTelefoneCelular,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: const Text(
                            "Conhecimentos*",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        gridCheckersMap(),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          children: [
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
                    const SizedBox(height: 32),
                    BlocListener<TecnicoBloc, TecnicoState>(
                      bloc: _tecnicoBloc,
                      listener: (context, state) {
                        if (state is TecnicoRegisterSuccessState) {
                          Navigator.pop(context);
                        } else if (state is TecnicoErrorState) {
                          final ErrorEntity error = state.error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "[ERROR]: ${error.errorMessage}",
                              ),
                            ),
                          );
                        }
                      },
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _registerTecnico,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            "Adicionar Técnico",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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
    _telefoneCelularController.dispose();
    _telefoneFixoController.dispose();
    _tecnicoBloc.close();
    _tecnicoCreateForm.dispose();
    super.dispose();
  }
}
