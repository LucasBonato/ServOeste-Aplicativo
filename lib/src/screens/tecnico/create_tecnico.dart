import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/components/mask_field.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';

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

  late TextEditingController nomeController,
      telefoneCelularController,
      telefoneFixoController;

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
    nomeController = TextEditingController();
    telefoneCelularController = TextEditingController();
    telefoneFixoController = TextEditingController();
  }

  Widget gridCheckersMap() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 0,
      childAspectRatio: 3,
      children: checkersMap.keys.map((label) {
        bool isChecked = checkersMap[label] ?? false; // Valor booleano associado a essa label
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 1,
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
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
                  value: isChecked,
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
                  },
                ),
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  // Tecnico includeData() {
  //   List<String> nomes = nomeController.text.split(" ");
  //   String nome = nomes.first;
  //   String sobrenome = "";
  //   for(int i = 1; i < nomes.length; i++){
  //     sobrenome += "${nomes[i]} ";
  //   }
  //   sobrenome = sobrenome.trim();
  //
  //   _telefoneCelular = transformarMask(telefoneCelularController.text);
  //   _telefoneFixo = transformarMask(telefoneFixoController.text);
  //
  //   List<int> especialidadesIds = [];
  //   checkersMap.forEach((label, isChecked) {
  //     if(isChecked){
  //       especialidadesIds.add(checkersMap.keys.toList().indexOf(label) + 1);
  //     }
  //   });
  //
  //   return Tecnico(
  //     nome: nome,
  //     sobrenome: sobrenome,
  //     telefoneCelular: _telefoneCelular,
  //     telefoneFixo: _telefoneFixo,
  //     especialidadesIds: especialidadesIds
  //   );
  // }

  bool _isValidForm() {
    _tecnicoFormKey.currentState?.validate();
    final ValidationResult response = _tecnicoCreateValidator.validate(_tecnicoCreateForm);
    return response.isValid;
  }

  void _registerTecnico() async {
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
          onPressed: () => Navigator.pop(context),
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
                      controller: nomeController,
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
                      controller: telefoneCelularController,
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
                      controller: telefoneFixoController,
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
                      //rowCheckersMap(),
                      Container(
                        child: gridCheckersMap()
                      ),
                      Text(validationCheckBoxes ? "Error" : "", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                        child: TextButton(
                          onPressed: _registerTecnico,
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
          ),
        )
      )
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneCelularController.dispose();
    telefoneFixoController.dispose();
    super.dispose();
  }
}
