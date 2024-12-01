import 'package:serv_oeste/src/components/custom_text_form_field.dart';
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
  late String _dropDownSituacaoValue;

  final Map<String, String> situationMap = {
    'a': Constants.situationTecnicoList[0],
    'l': Constants.situationTecnicoList[1],
    'd': Constants.situationTecnicoList[2],
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
    _dropDownSituacaoValue = Constants.situationTecnicoList.first;
    _tecnicoBloc.add(TecnicoSearchOneEvent(id: widget.id));
  }

  Widget gridCheckersMap() {
    return FormField(
      validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, "conhecimentos"),
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
                    child: Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (field.errorText != null)
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
    _tecnicoUpdateValidator.setConhecimentos(_tecnicoUpdateForm.conhecimentos.value);

    if (_isValidForm() == false) {
      return;
    }

    List<String> nomes = _tecnicoUpdateForm.nome.value.split(" ");
    _tecnicoUpdateForm.nome.value = nomes.first;
    String sobrenome = nomes
        .sublist(1)
        .join(" ")
        .trim();

    _tecnicoBloc.add(TecnicoUpdateEvent(tecnico: Tecnico.fromForm(_tecnicoUpdateForm), sobrenome: sobrenome));
    _tecnicoUpdateForm.nome.value = "${nomes.first} $sobrenome";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, ""),
        ),
        title: const Text("Atualize o Técnico: "),
        centerTitle: true,
      ),
      body: BlocBuilder<TecnicoBloc, TecnicoState>(
        bloc: _tecnicoBloc,
        buildWhen: (previousState, currentState) {
          if (currentState is TecnicoSearchOneSuccessState) {
            String nomeCompletoTecnico = "${currentState.tecnico.nome} ${currentState.tecnico.sobrenome}";
            _tecnicoUpdateForm.setNome(nomeCompletoTecnico);
            _tecnicoUpdateForm.setTelefoneCelular(currentState.tecnico.telefoneCelular);
            _tecnicoUpdateForm.setTelefoneCelular(currentState.tecnico.telefoneFixo);
            _nomeController.text = nomeCompletoTecnico;
            _telefoneCelularController.text = currentState.tecnico.telefoneCelular!;
            _telefoneFixoController.text = currentState.tecnico.telefoneFixo!;

            final initial = currentState.tecnico.situacao?.toLowerCase()[0] ?? '';
            _dropDownSituacaoValue = situationMap[initial] ?? _dropDownSituacaoValue;

            if (currentState.tecnico.especialidades != null) {
              for (Especialidade especialidade in currentState.tecnico.especialidades!) {
                if (!checkersMap.keys.contains(especialidade.conhecimento)) continue;
                checkersMap[especialidade.conhecimento] = true;
              }
            }
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return switch (state) {
            TecnicoSearchOneSuccessState() => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _tecnicoFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DropdownButtonFormField<String>(
                          validator: _tecnicoUpdateValidator.byField(
                              _tecnicoUpdateForm, "situacao"),
                          value: _dropDownSituacaoValue,
                          items: Constants.situationTecnicoList
                              .map((String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            _tecnicoUpdateForm.setSituacao(value);
                            setState(() {
                              _dropDownSituacaoValue = value!;
                            });
                          },
                        ),
                        Column(
                          children: [
                            CustomTextFormField(
                              hint: "Nome...",
                              label: "Nome",
                              type: TextInputType.name,
                            maxLength: 40,
                            hide: false,
                            valueNotifier: _tecnicoUpdateForm.nome,
                            validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, "nome"),
                            onChanged: _tecnicoUpdateForm.setNome,
                          ),
                          CustomTextFormField(
                            hint: "(99) 99999-9999",
                            label: "Telefone Celular",
                            masks: Constants.maskTelefone,
                            type: TextInputType.phone,
                            maxLength: 15,
                            hide: false,
                            valueNotifier: _tecnicoUpdateForm.telefoneCelular,
                            validator: _tecnicoUpdateValidator.byField(_tecnicoUpdateForm, "telefoneCelular"),
                            onChanged: _tecnicoUpdateForm.setTelefoneCelular,
                          ),
                          CustomTextFormField(
                            hint: "(99) 99999-9999",
                            label: "Telefone Fixo",
                            masks: Constants.maskTelefone,
                              type: TextInputType.phone,
                              maxLength: 15,
                              hide: false,
                              valueNotifier: _tecnicoUpdateForm.telefoneFixo,
                              validator: _tecnicoUpdateValidator.byField(
                                  _tecnicoUpdateForm, "telefoneFixo"),
                              onChanged: _tecnicoUpdateForm.setTelefoneFixo,
                            ),
                          ],
                        ),
                        gridCheckersMap(),
                        ElevatedButton(
                          onPressed: () {
                            if (_tecnicoFormKey.currentState!.validate()) {
                              _updateTecnico();
                            }
                          },
                          child: const Text("Salvar"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            TecnicoErrorState() =>
              Center(child: Text(state.error.errorMessage)),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }

  @override
  void dispose() {
    _tecnicoBloc.close();
    _tecnicoUpdateForm.dispose();
    _nomeController.dispose();
    _telefoneCelularController.dispose();
    _telefoneFixoController.dispose();
    super.dispose();
  }
}
