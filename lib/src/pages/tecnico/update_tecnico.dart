import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/util/constants.dart';
import 'package:serv_oeste/src/services/tecnico_service.dart';

import '../../widgets/mask_field.dart';
import '../../models/tecnico.dart';

class UpdateTecnico extends StatefulWidget {
  final int id;

  const UpdateTecnico({super.key, required this.id});

  @override
  State<UpdateTecnico> createState() => _UpdateTecnicoState();
}

class _UpdateTecnicoState extends State<UpdateTecnico> {
  Tecnico? tecnico;
  bool isLoading = true,
      isCheckersAndNameLoaded = false;

  late TextEditingController nomeController,
      telefoneCelularController,
      telefoneFixoController;

  bool validationNome = false,
      validationTelefoneCelular = false,
      validationTelefoneFixo = false,
      validationCheckBoxes = false;

  String _errorMessage = "",
      _telefoneCelular = "",
      _telefoneFixo = "",
      _dropDownValue = "";

  Map<String, bool> checkersMap = {
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

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
    telefoneCelularController = TextEditingController();
    telefoneFixoController = TextEditingController();
    loadTecnico();
  }
  @override
  void dispose() {
    nomeController.dispose();
    telefoneCelularController.dispose();
    telefoneFixoController.dispose();
    super.dispose();
  }

  void loadTecnico() async {
    try {
      Tecnico? tecnico = await TecnicoService().getById(widget.id);
      setState(() {
        this.tecnico = tecnico;
        isLoading = false;
      });
    } catch (e) {
      Logger().e("Erro ao carregar o técnico: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
    setErrorCheckBox(String errorMessage){
      _errorMessage = errorMessage;
      validationCheckBoxes = true;
    }
    setState(() {
      validationNome = false;
      validationTelefoneCelular = false;
      validationTelefoneFixo = false;
      validationCheckBoxes = false;
      _errorMessage = "";

      switch(erro){
        case 1: setErrorNome(errorMessage); break;
        case 2: setErrorTelefoneCelular(errorMessage); break;
        case 3: setErrorTelefoneFixo(errorMessage); break;
        case 4: setErrorTelefones(errorMessage); break;
        case 5: setErrorCheckBox(errorMessage); break;
      }
    });
  }

  Tecnico includeData() {
    List<String> nomes = nomeController.text.split(" ");
    String nome = nomes.first;
    String sobrenome = "";
    for(int i = 1; i < nomes.length; i++){
      sobrenome += "${nomes[i]} ";
    }
    sobrenome = sobrenome.trim();

    _telefoneCelular = Constants.transformarMask(telefoneCelularController.text);
    _telefoneFixo = Constants.transformarMask(telefoneFixoController.text);

    List<int> especialidadesIds = [];
    checkersMap.forEach((label, isChecked) {
      if(isChecked){
        especialidadesIds.add(checkersMap.keys.toList().indexOf(label) + 1);
      }
    });

    return Tecnico(
        id: widget.id,
        nome: nome,
        sobrenome: sobrenome,
        telefoneCelular: _telefoneCelular,
        telefoneFixo: _telefoneFixo,
        situacao: _dropDownValue.toLowerCase(),
        especialidadesIds: especialidadesIds
    );
  }

  void updateTecnico(BuildContext context) async {
    Tecnico tecnico = includeData();
    dynamic body = await TecnicoService().update(tecnico);

    if(body == null && context.mounted) {
      Navigator.pop(context);
      return;
    }

    setError(body["idError"], body["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Atualize o Técnico: "),
        centerTitle: true,
      ),
      body: (isLoading) ? const Center(
          child: CircularProgressIndicator(),
      ) : buildTecnicoUpdatePage(tecnico)
    );
  }

  Widget buildTecnicoUpdatePage(Tecnico? tecnico){
    if(!isCheckersAndNameLoaded) {

      if(tecnico!.situacao!.toLowerCase().startsWith("a")) _dropDownValue = Constants.list[0];
      if(tecnico.situacao!.toLowerCase().startsWith("l")) _dropDownValue = Constants.list[1];
      if(tecnico.situacao!.toLowerCase().startsWith("d")) _dropDownValue = Constants.list[2];

      nomeController = TextEditingController(text: "${tecnico.nome} ${tecnico.sobrenome}");
      telefoneCelularController = TextEditingController(text: (tecnico.telefoneCelular == null || tecnico.telefoneCelular == "") ? "" : Constants.deTransformarMask(tecnico.telefoneCelular!));
      telefoneFixoController = TextEditingController(text: (tecnico.telefoneFixo == null || tecnico.telefoneFixo == "") ? "" : Constants.deTransformarMask(tecnico.telefoneFixo!));

      if (tecnico.especialidades != null) {
        for (Especialidade especialidade in tecnico.especialidades!) {
          if (checkersMap.keys.contains(especialidade.conhecimento)) {
            setState(() {
              checkersMap[especialidade.conhecimento] = true;
            });
          }
        }
      }
      isCheckersAndNameLoaded = true;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            DropdownButton<String>(
              value: _dropDownValue,
              items: Constants.list.map<DropdownMenuItem<String>>((String value) =>
                  DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  )
              ).toList(),
              onChanged: (valorSelecionado) {
                setState(() {
                  _dropDownValue = valorSelecionado!;
                });
              }
            ),
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
                ),
                CustomMaskField(
                  hint: "(99) 99999-9999",
                  label: "Telefone Celular",
                  mask: (telefoneCelularController.text.isEmpty) ? "(##) #####-####" : null,
                  errorMessage: _errorMessage,
                  maxLength: 15,
                  controller: telefoneCelularController,
                  validation: validationTelefoneCelular,
                  type: TextInputType.phone,
                ),
                CustomMaskField(
                  hint: "(99) 99999-9999",
                  label: "Telefone Fixo",
                  mask: (telefoneFixoController.text.isEmpty) ? "(##) #####-####" : null,
                  errorMessage: _errorMessage,
                  maxLength: 15,
                  controller: telefoneFixoController,
                  validation: validationTelefoneFixo,
                  type: TextInputType.phone,
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
                  Text(validationCheckBoxes ? _errorMessage : "", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: TextButton(
                      onPressed: () => updateTecnico(context),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                      ),
                      child: const Text("Atualizar"),
                    ),
                  ),
                ],
              ),
            )
          ]
        ),
      )
    );
  }
}
