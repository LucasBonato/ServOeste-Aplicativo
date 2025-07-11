import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/layout/app_bar_form.dart';
import 'package:serv_oeste/src/components/screen/elevated_form_button.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/formatters.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class UpdateTecnico extends StatefulWidget {
  final int id;

  const UpdateTecnico({super.key, required this.id});

  @override
  State<UpdateTecnico> createState() => _UpdateTecnicoState();
}

class _UpdateTecnicoState extends State<UpdateTecnico> {
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  final TecnicoForm _tecnicoUpdateForm = TecnicoForm();
  final TecnicoValidator _tecnicoUpdateValidator = TecnicoValidator(isUpdate: true);
  final GlobalKey<FormState> _tecnicoFormKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController, _telefoneCelularController, _telefoneFixoController, _outrosController;
  late ValueNotifier<String> _dropDownSituacaoValue;

  final Map<String, String> situationMap = {
    'ATIVO': 'Ativo',
    'LICENCA': 'Licença',
    'DESATIVADO': 'Desativado',
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

  bool _outrosSelected = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneCelularController = TextEditingController();
    _telefoneFixoController = TextEditingController();
    _outrosController = TextEditingController();
    _tecnicoUpdateForm.setId(widget.id);
    String defaultSituacao = Constants.situationTecnicoList.first;
    _dropDownSituacaoValue = ValueNotifier<String>(defaultSituacao);
    _tecnicoUpdateForm.setSituacao(defaultSituacao);
    _tecnicoBloc.add(TecnicoSearchOneEvent(id: widget.id));
  }

  Widget gridCheckersMap() {
    return FormField(
      validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, "conhecimentos"),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
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
                            if (label == "Outros") {
                              _outrosSelected = value;
                            }
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
          if (_outrosSelected)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _outrosController,
                    decoration: InputDecoration(
                      labelText: 'Digite os itens separados por vírgula',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exemplo: Ar condicionado, Ventilador, Freezer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
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

    if (_outrosSelected && _outrosController.text.isNotEmpty) {
      List<String> outrosItens = _outrosController.text.split(",");
      for (var item in outrosItens) {
        item = item.trim();
        if (item.isNotEmpty) {
          _tecnicoUpdateForm.addConhecimentos(checkersMap.length + 1);
        }
      }
    }

    _tecnicoUpdateValidator.setConhecimentos(_tecnicoUpdateForm.conhecimentos.value);

    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoUpdateForm.nome.value.split(" ");
    _tecnicoUpdateForm.nome.value = nomes.first;
    String sobrenome = nomes.sublist(1).join(" ").trim();

    _tecnicoBloc.add(TecnicoUpdateEvent(tecnico: Tecnico.fromForm(_tecnicoUpdateForm), sobrenome: sobrenome));
    _tecnicoUpdateForm.nome.value = "${nomes.first} $sobrenome";
  }

  void _handleBackNavigation() {
    _tecnicoBloc.add(TecnicoSearchMenuEvent());
    Navigator.pop(context, "Back");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBarForm(
        title: "Voltar",
        onPressed: _handleBackNavigation,
      ),
      body: BlocListener<TecnicoBloc, TecnicoState>(
        bloc: _tecnicoBloc,
        listener: (context, state) {
          if (state is TecnicoUpdateSuccessState) {
            _handleBackNavigation();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Técnico atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)",
              ),
            ));
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
              String nomeCompletoTecnico = "${currentState.tecnico.nome} ${currentState.tecnico.sobrenome}";
              _tecnicoUpdateForm.setNome(nomeCompletoTecnico);
              _tecnicoUpdateForm.telefoneFixo.value = (currentState.tecnico.telefoneFixo!.isEmpty ? "" : Formatters.applyTelefoneMask(currentState.tecnico.telefoneFixo!));
              _tecnicoUpdateForm.telefoneCelular.value = (currentState.tecnico.telefoneCelular!.isEmpty ? "" : Formatters.applyCelularMask(currentState.tecnico.telefoneCelular!));
              _nomeController.text = nomeCompletoTecnico;
              _telefoneFixoController.text = currentState.tecnico.telefoneFixo ?? '';
              _telefoneCelularController.text = currentState.tecnico.telefoneCelular ?? '';

              final tecnicoSituacao = currentState.tecnico.situacao ?? '';
              final mappedSituacao = situationMap[tecnicoSituacao] ?? 'Situação...';

              _dropDownSituacaoValue.value = mappedSituacao;

              if (currentState.tecnico.especialidades != null) {
                for (Especialidade especialidade in currentState.tecnico.especialidades!) {
                  if (!checkersMap.keys.contains(especialidade.conhecimento)) {
                    continue;
                  }
                  checkersMap[especialidade.conhecimento] = true;
                }

                List<String> outrosItens = currentState.tecnico.especialidades!.where((e) => e.conhecimento == "Outros").map((e) => e.conhecimento).toList();
                if (outrosItens.isNotEmpty) {
                  _outrosController.text = outrosItens.join(", ");
                  _outrosSelected = true;
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
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false, scrollbars: false),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _tecnicoFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "Consultar/Atualizar Técnico",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 48),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 400) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFormField(
                                        hint: "Nome...",
                                        label: "Nome*",
                                        type: TextInputType.name,
                                        maxLength: 40,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        hide: false,
                                        valueNotifier: _tecnicoUpdateForm.nome,
                                        validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.nomeESobrenome.name),
                                        onChanged: _tecnicoUpdateForm.setNome,
                                      ),
                                      CustomDropdownFormField(
                                        label: "Situação",
                                        dropdownValues: Constants.situationTecnicoList,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        valueNotifier: _dropDownSituacaoValue,
                                        validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.situacao.name),
                                        onChanged: (String? value) {
                                          _tecnicoUpdateForm.setSituacao(value);
                                          setState(() {
                                            _dropDownSituacaoValue.value = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextFormField(
                                          hint: "Nome...",
                                          label: "Nome*",
                                          type: TextInputType.name,
                                          maxLength: 40,
                                          rightPadding: 4,
                                          hide: false,
                                          valueNotifier: _tecnicoUpdateForm.nome,
                                          validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.nomeESobrenome.name),
                                          onChanged: _tecnicoUpdateForm.setNome,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: CustomDropdownFormField(
                                          label: "Situação",
                                          dropdownValues: Constants.situationTecnicoList,
                                          leftPadding: 4,
                                          valueNotifier: _dropDownSituacaoValue,
                                          validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.situacao.name),
                                          onChanged: (String? value) {
                                            _tecnicoUpdateForm.setSituacao(value);
                                            setState(() {
                                              _dropDownSituacaoValue.value = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 400) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFormField(
                                        hint: "Telefone Fixo...",
                                        label: "Telefone Fixo**",
                                        type: TextInputType.phone,
                                        maxLength: 14,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        hide: true,
                                        masks: InputMasks.telefoneFixo,
                                        valueNotifier: _tecnicoUpdateForm.telefoneFixo,
                                        validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.telefones.name),
                                        onChanged: _tecnicoUpdateForm.setTelefoneFixo,
                                      ),
                                      CustomTextFormField(
                                        hint: "Telefone Celular...",
                                        label: "Telefone Celular**",
                                        type: TextInputType.phone,
                                        maxLength: 15,
                                        leftPadding: 4,
                                        rightPadding: 4,
                                        hide: true,
                                        masks: InputMasks.telefoneCelular,
                                        valueNotifier: _tecnicoUpdateForm.telefoneCelular,
                                        validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.telefones.name),
                                        onChanged: _tecnicoUpdateForm.setTelefoneCelular,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          hint: "Telefone Fixo...",
                                          label: "Telefone Fixo**",
                                          type: TextInputType.phone,
                                          maxLength: 14,
                                          rightPadding: 4,
                                          hide: true,
                                          masks: InputMasks.telefoneFixo,
                                          valueNotifier: _tecnicoUpdateForm.telefoneFixo,
                                          validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.telefones.name),
                                          onChanged: _tecnicoUpdateForm.setTelefoneFixo,
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomTextFormField(
                                          hint: "Telefone Celular...",
                                          label: "Telefone Celular**",
                                          type: TextInputType.phone,
                                          maxLength: 15,
                                          leftPadding: 4,
                                          hide: true,
                                          masks: InputMasks.telefoneCelular,
                                          valueNotifier: _tecnicoUpdateForm.telefoneCelular,
                                          validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, ErrorCodeKey.telefones.name),
                                          onChanged: _tecnicoUpdateForm.setTelefoneCelular,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
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
                            const Padding(padding: EdgeInsets.only(top: 8, left: 16), child: BuildFieldLabels()),
                            const SizedBox(height: 28),
                            Center(
                              child: ElevatedFormButton(
                                text: "Atualizar Técnico",
                                onPressed: _updateTecnico,
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
          },
        ),
      ),
    );
  }
}
