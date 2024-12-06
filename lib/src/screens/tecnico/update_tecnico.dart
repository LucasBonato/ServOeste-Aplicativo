import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class UpdateTecnico extends StatefulWidget {
  final int id;

  const UpdateTecnico({super.key, required this.id});

  @override
  State<UpdateTecnico> createState() => _UpdateTecnicoState();
}

class _UpdateTecnicoState extends State<UpdateTecnico> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  final TecnicoForm _tecnicoUpdateForm = TecnicoForm();
  final TecnicoValidator _tecnicoUpdateValidator = TecnicoValidator();
  final GlobalKey<FormState> _tecnicoFormKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController,
      _telefoneCelularController,
      _telefoneFixoController;
  late ValueNotifier<String> _dropDownSituacaoValue;

  final Map<String, String> situationMap = {
    'Ativo': Constants.situationTecnicoList[1]['label'],
    'Licença': Constants.situationTecnicoList[2]['label'],
    'Desativado': Constants.situationTecnicoList[3]['label'],
  };

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
    _tecnicoUpdateForm.setId(widget.id);

    _dropDownSituacaoValue =
        ValueNotifier<String>(Constants.situationTecnicoList.first['label']);

    _tecnicoBloc.add(TecnicoSearchOneEvent(id: widget.id));
  }

  Widget gridCheckersMap() {
    return FormField(
      validator:
          _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, "conhecimentos"),
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
                return Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: checkersMap[label] ?? false,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            checkersMap[label] = value;
                          });
                          field.reset();
                        },
                      ),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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
    return _tecnicoUpdateValidator.validate(_tecnicoUpdateForm).isValid;
  }

  void _updateTecnico() {
    checkersMap.forEach((label, isChecked) {
      int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
      if (isChecked) {
        _tecnicoUpdateForm.addConhecimentos(idConhecimento);
      } else {
        _tecnicoUpdateForm.removeConhecimentos(idConhecimento);
      }
    });
    _tecnicoUpdateValidator
        .setConhecimentos(_tecnicoUpdateForm.conhecimentos.value);

    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoUpdateForm.nome.value.split(" ");
    _tecnicoUpdateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _tecnicoBloc.add(TecnicoUpdateEvent(
        tecnico: Tecnico.fromForm(_tecnicoUpdateForm), sobrenome: sobrenome));
    _tecnicoUpdateForm.nome.value = "${nomes.first} $sobrenome";
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
              ),
            ],
          ),
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: const Color(0xFCFDFDFF),
        elevation: 0,
      ),
      body: BlocListener<TecnicoBloc, TecnicoState>(
        bloc: _tecnicoBloc,
        listener: (context, state) {
          if (state is TecnicoUpdateSuccessState) {
            Navigator.pop(context);
          } else if (state is TecnicoErrorState) {
            ErrorEntity error = state.error;

            _tecnicoUpdateValidator.applyBackendError(error);
            _tecnicoFormKey.currentState?.validate();
            _tecnicoUpdateValidator.cleanExternalErrors();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "[ERROR] Informação(ões) inválida(s) ao atualizar o Técnico: ${error.errorMessage}",
              ),
            ));
          }
        },
        child: BlocBuilder<TecnicoBloc, TecnicoState>(
          bloc: _tecnicoBloc,
          buildWhen: (previousState, currentState) {
            if (currentState is TecnicoSearchOneSuccessState) {
              String nomeCompletoTecnico =
                  "${currentState.tecnico.nome} ${currentState.tecnico.sobrenome}";
              _tecnicoUpdateForm.setNome(nomeCompletoTecnico);
              _tecnicoUpdateForm
                  .setTelefoneFixo(currentState.tecnico.telefoneFixo);
              _tecnicoUpdateForm
                  .setTelefoneCelular(currentState.tecnico.telefoneCelular);

              _nomeController.text = nomeCompletoTecnico;
              _telefoneFixoController.text =
                  currentState.tecnico.telefoneFixo ?? '';
              _telefoneCelularController.text =
                  currentState.tecnico.telefoneCelular ?? '';

              final tecnicoSituacao =
                  currentState.tecnico.situacao?.toLowerCase() ?? '';
              _dropDownSituacaoValue.value =
                  situationMap[tecnicoSituacao] ?? _dropDownSituacaoValue.value;

              if (currentState.tecnico.especialidades != null) {
                for (Especialidade especialidade
                    in currentState.tecnico.especialidades!) {
                  if (!checkersMap.keys.contains(especialidade.conhecimento))
                    continue;
                  checkersMap[especialidade.conhecimento] = true;
                }
              }
              return true;
            }
            return false;
          },
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _tecnicoFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Atualizar Técnico",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextFormField(
                                  hint: "Nome...",
                                  label: "Nome*",
                                  type: TextInputType.name,
                                  maxLength: 40,
                                  rightPadding: 8,
                                  hide: false,
                                  valueNotifier: _tecnicoUpdateForm.nome,
                                  validator: _tecnicoUpdateValidator.byField(
                                      _tecnicoUpdateForm,
                                      ErrorCodeKey.nomeESobrenome.name),
                                  onChanged: _tecnicoUpdateForm.setNome,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: CustomDropdownField(
                                  label: "Situação",
                                  leftPadding: 0,
                                  valueNotifier: _dropDownSituacaoValue,
                                  validator: _tecnicoUpdateValidator.byField(
                                      _tecnicoUpdateForm, "situacao"),
                                  dropdownValues: Constants.situationTecnicoList
                                      .map((item) => item['label'] as String)
                                      .toList(),
                                  onChanged: (String? value) {
                                    _tecnicoUpdateForm.setSituacao(value);
                                    setState(() {
                                      _dropDownSituacaoValue.value = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  hint: "Telefone Fixo...",
                                  label: "Telefone Fixo**",
                                  type: TextInputType.phone,
                                  maxLength: 14,
                                  rightPadding: 8,
                                  hide: false,
                                  // masks: Constants.maskTelefoneFixo,
                                  valueNotifier:
                                      _tecnicoUpdateForm.telefoneFixo,
                                  validator: _tecnicoUpdateValidator.byField(
                                      _tecnicoUpdateForm,
                                      ErrorCodeKey.telefones.name),
                                  onChanged: _tecnicoUpdateForm.setTelefoneFixo,
                                ),
                              ),
                              Expanded(
                                child: CustomTextFormField(
                                  hint: "Telefone Celular...",
                                  label: "Telefone Celular**",
                                  type: TextInputType.phone,
                                  maxLength: 15,
                                  leftPadding: 0,
                                  hide: false,
                                  masks: Constants.maskTelefone,
                                  valueNotifier:
                                      _tecnicoUpdateForm.telefoneCelular,
                                  validator: _tecnicoUpdateValidator.byField(
                                      _tecnicoUpdateForm,
                                      ErrorCodeKey.telefones.name),
                                  onChanged:
                                      _tecnicoUpdateForm.setTelefoneCelular,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  "Conhecimentos*",
                                  style: TextStyle(
                                    fontSize: 16,
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
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "** - Preencha ao menos um destes campos",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: ElevatedButton(
                              onPressed: _updateTecnico,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text(
                                "Atualizar Técnico",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
