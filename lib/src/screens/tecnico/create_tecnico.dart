import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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
    "Outros": false
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
      validator: _tecnicoCreateValidator.byField(_tecnicoCreateForm, "conhecimentos"),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: (MediaQuery.of(context).size.width < 450) ? 2 : 3,
            crossAxisSpacing: 0,
            childAspectRatio: 5,
            children: checkersMap.keys.map((label) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.blueAccent,
                        checkboxTheme: const CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                      child: Checkbox(
                        value: checkersMap[label] ?? false,
                        activeColor: Colors.blue,
                        side: const BorderSide(
                          width: 2,
                          color: Colors.blueAccent,
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            checkersMap[label] = value;
                          });
                          field.reset();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }).toList(),
          ),
          if (field.errorText != null) // Exibe o erro abaixo da GridView
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  textAlign: TextAlign.center,
                  field.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isValidForm() {
    _tecnicoFormKey.currentState?.validate();
    final ValidationResult response = _tecnicoCreateValidator.validate(_tecnicoCreateForm);
    return response.isValid;
  }

  void _registerTecnico() {
    checkersMap.forEach((label, isChecked) {
      int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
      if(isChecked){
        _tecnicoCreateForm.addConhecimentos(idConhecimento);
      } else {
        _tecnicoCreateForm.removeConhecimentos(idConhecimento);
      }
    });
    _tecnicoCreateValidator.setConhecimentos(_tecnicoCreateForm.conhecimentos.value);

    if(_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoCreateForm.nome.value.split(" ");
    _tecnicoCreateForm.nome.value = nomes.first;
    String sobrenome = nomes
        .sublist(1)
        .join(" ")
        .trim();

    _tecnicoBloc.add(TecnicoRegisterEvent(tecnico: Tecnico.fromForm(_tecnicoCreateForm), sobrenome: sobrenome));
    _tecnicoCreateForm.nome.value = "${nomes.first} $sobrenome";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, "Back"),
        ),
        title: const Text("Novo Técnico"),
        centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: SingleChildScrollView(
          child: Form(
            key: _tecnicoFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  children: [
                    CustomTextFormField(
                      hint: "Nome...",
                      label: "Nome",
                      controller: _nomeController,
                      type: TextInputType.name,
                      maxLength: 40,
                      hide: false,
                      valueNotifier: _tecnicoCreateForm.nome,
                      validator: _tecnicoCreateValidator.byField(_tecnicoCreateForm, "nome"),
                      onChanged: _tecnicoCreateForm.setNome,
                    ),
                    CustomTextFormField(
                      hint: "(99) 99999-9999",
                      label: "Telefone Celular",
                      controller: _telefoneCelularController,
                      masks: Constants.maskTelefone,
                      type: TextInputType.phone,
                      maxLength: 15,
                      hide: false,
                      valueNotifier: _tecnicoCreateForm.telefoneCelular,
                      validator: _tecnicoCreateValidator.byField(_tecnicoCreateForm, "telefoneCelular"),
                      onChanged: _tecnicoCreateForm.setTelefoneCelular,
                    ),
                    CustomTextFormField(
                      hint: "(99) 99999-9999",
                      label: "Telefone Fixo",
                      masks: Constants.maskTelefone,
                      controller: _telefoneFixoController,
                      type: TextInputType.phone,
                      maxLength: 15,
                      hide: false,
                      valueNotifier: _tecnicoCreateForm.telefoneFixo,
                      validator: _tecnicoCreateValidator.byField(_tecnicoCreateForm, "telefoneFixo"),
                      onChanged: _tecnicoCreateForm.setTelefoneFixo,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Selecione os conhecimentos do Técnico:', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                      Container(
                        child: gridCheckersMap()
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                        child: BlocListener<TecnicoBloc, TecnicoState>(
                          bloc: _tecnicoBloc,
                          listener: (context, state) {
                            if (state is TecnicoRegisterSuccessState) {
                              Navigator.pop(context);
                            }
                            else if (state is TecnicoErrorState) {
                              ErrorEntity error = state.error;

                              _tecnicoCreateValidator.applyBackendError(error);
                              _tecnicoFormKey.currentState?.validate();
                              _tecnicoCreateValidator.cleanExternalErrors();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("[ERROR] Informação(ões) inválida(s) ao registrar o Técnico: ${error.errorMessage}"))
                              );

                            }
                          },
                          child: ElevatedButton(
                            onPressed: _registerTecnico,
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
    _nomeController.dispose();
    _telefoneCelularController.dispose();
    _telefoneFixoController.dispose();
    _tecnicoBloc.close();
    _tecnicoCreateForm.dispose();
    super.dispose();
  }
}