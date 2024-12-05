import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_grid_checkers_form_field.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class CreateTecnico extends StatefulWidget {
  const CreateTecnico({super.key});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  late final TecnicoBloc _tecnicoBloc;
  final TecnicoForm _tecnicoCreateForm = TecnicoForm();
  final TecnicoValidator _tecnicoCreateValidator = TecnicoValidator();
  final GlobalKey<FormState> _tecnicoFormKey = GlobalKey<FormState>();

  late TextEditingController _nomeController,
      _telefoneCelularController,
      _telefoneFixoController;

  bool validationCheckBoxes = false;

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
    _tecnicoBloc = context.read<TecnicoBloc>();
    _nomeController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _telefoneFixoController = TextEditingController();
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
      backgroundColor: const Color(0xFFF9F9FF),
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
                    CustomTextFormField(
                      hint: "Nome...",
                      label: "Nome*",
                      type: TextInputType.name,
                      maxLength: 40,
                      rightPadding: 0,
                      leftPadding: 0,
                      hide: false,
                      valueNotifier: _tecnicoCreateForm.nome,
                      validator: _tecnicoCreateValidator.byField(
                          _tecnicoCreateForm, ErrorCodeKey.nomeESobrenome.name),
                      onChanged: _tecnicoCreateForm.setNome,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hint: "(99) 9999-9999",
                            label: "Telefone Fixo**",
                            leftPadding: 0,
                            maxLength: 14,
                            hide: false,
                            masks: [
                              MaskTextInputFormatter(mask: '(##) ####-####'),
                            ],
                            type: TextInputType.phone,
                            valueNotifier: _tecnicoCreateForm.telefoneFixo,
                            validator: _tecnicoCreateValidator.byField(
                                _tecnicoCreateForm,
                                ErrorCodeKey.telefoneFixo.name),
                            onChanged: _tecnicoCreateForm.setTelefoneFixo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            hint: "(99) 99999-9999",
                            label: "Telefone Celular**",
                            leftPadding: 0,
                            maxLength: 15,
                            hide: false,
                            masks: Constants.maskTelefone,
                            type: TextInputType.phone,
                            valueNotifier: _tecnicoCreateForm.telefoneCelular,
                            validator: _tecnicoCreateValidator.byField(
                                _tecnicoCreateForm,
                                ErrorCodeKey.telefoneCelular.name),
                            onChanged: _tecnicoCreateForm.setTelefoneCelular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Conhecimentos*",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomGridCheckersFormField(
                            validator: _tecnicoCreateValidator.byField(
                                _tecnicoCreateForm,
                                ErrorCodeKey.conhecimento.name),
                            checkersMap: checkersMap),
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
                          ErrorEntity error = state.error;

                          _tecnicoCreateValidator.applyBackendError(error);
                          _tecnicoFormKey.currentState?.validate();
                          _tecnicoCreateValidator.cleanExternalErrors();

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "[ERROR] Informação(ões) inválida(s) ao registrar o Técnico: ${error.errorMessage}")));
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
    _tecnicoCreateForm.dispose();
    super.dispose();
  }
}
