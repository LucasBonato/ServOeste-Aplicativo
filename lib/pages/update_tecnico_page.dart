import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../components/mask_field.dart';
import '../models/tecnico.dart';
import '../service/tecnico_service.dart';

const List<String> list = <String>['Ativo', 'Licença', 'Desativado'];

class UpdateTecnico extends StatefulWidget {
  final VoidCallback onIconPressed;
  final int id;

  const UpdateTecnico({super.key, required this.onIconPressed, required this.id});

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
      _dropDownValue = list.first;

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

  Widget rowCheckersMap() {
    List<Row> rows = [];
    List<Column> columns = [];
    checkersMap.forEach((label, isChecked) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Theme(
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
                  if(value == null) return;
                  setState(() {
                    checkersMap[label] = value;
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
    for (int i = 0; i < rows.length; i += 4) {
      columns.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rows.sublist(i, i + 4),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: columns,
    );
  }

  @override
  void initState() {
    super.initState();
    loadTecnico();
  }
  @override
  void dispose() {
    nomeController.dispose();
    telefoneCelularController.dispose();
    telefoneFixoController.dispose();
    super.dispose();
  }

  Future<void> loadTecnico() async {
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

  String transformarMask(String telefone){
    if(telefone != ""){
      String telefoneFormatado = "${telefone.substring(1, 3)}${telefone.substring(5, 10)}${telefone.substring(11)}";
      return telefoneFormatado;
    }
    return "";
  }
  String deTransformarMask(String telefone){
    String telefoneFormatado = "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
    return telefoneFormatado;
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

    _telefoneCelular = transformarMask(telefoneCelularController.text);
    _telefoneFixo = transformarMask(telefoneFixoController.text);

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

  void updateTecnico() async {
    TecnicoService tecnicoService = TecnicoService();
    Tecnico tecnico = includeData();
    dynamic body = await tecnicoService.update(tecnico);

    if(body == null) {
      widget.onIconPressed();
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
          onPressed: widget.onIconPressed,
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
      nomeController = TextEditingController(text: "${tecnico!.nome} ${tecnico.sobrenome}");
      telefoneCelularController = TextEditingController(text: (tecnico.telefoneCelular == null || tecnico.telefoneCelular == "") ? "" : deTransformarMask(tecnico.telefoneCelular!));
      telefoneFixoController = TextEditingController(text: (tecnico.telefoneFixo == null || tecnico.telefoneFixo == "") ? "" : deTransformarMask(tecnico.telefoneFixo!));

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
              items: list.map<DropdownMenuItem<String>>((String value) =>
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
                  rowCheckersMap(),
                  Text(validationCheckBoxes ? _errorMessage : "", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: TextButton(
                      onPressed: updateTecnico,
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
