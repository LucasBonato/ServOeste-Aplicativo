import 'package:flutter/material.dart';
import 'package:serv_oeste/components/mask_field.dart';
import 'package:serv_oeste/models/tecnico.dart';
import 'package:serv_oeste/service/tecnico_service.dart';

class CreateTecnico extends StatefulWidget {
  final VoidCallback onIconPressed;

  const CreateTecnico({super.key, required this.onIconPressed});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  late TextEditingController nomeController,
      telefoneCelularController,
      telefoneFixoController;

  bool validationNome = false,
      validationTelefoneCelular = false,
      validationTelefoneFixo = false,
      validationCheckBoxes = false;

  String _errorMessage = "",
    _telefoneCelular = "",
    _telefoneFixo = "";

  Map<String, bool> checkersMap = {
    "Adega": false,
    "Cooler": false,
    "Lava Louca": false,
    "Purificador": false,
    "Bebedouro": false,
    "Frigobar": false,
    "Lava Roupa": false,
    "Secadora": false,
    "Climatizador": false,
    "Geladeira": false,
    "Microondas": false,
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
                  setState(() {
                    checkersMap[label] = value!;
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
    nomeController = TextEditingController();
    telefoneCelularController = TextEditingController();
    telefoneFixoController = TextEditingController();
  }
  @override
  void dispose() {
    nomeController.dispose();
    telefoneCelularController.dispose();
    telefoneFixoController.dispose();
    super.dispose();
  }

  String transformarMask(String telefone){
    List<String> charsDeTelefone = telefone.split("");
    String telefoneFormatado = "";
    for(int i = 0; i < charsDeTelefone.length; i++){
      if(i == 0) continue;
      if(i == 3) continue;
      if(i == 4) continue;
      if(i == 10) continue;
      telefoneFormatado += charsDeTelefone[i];
    }
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

      switch(erro){
        case 1: setErrorNome(errorMessage);
        break;
        case 2: setErrorTelefoneCelular(errorMessage);
        break;
        case 3: setErrorTelefoneFixo(errorMessage);
        break;
        case 4: setErrorTelefones(errorMessage);
        break;
        case 5: setErrorCheckBox(errorMessage);
        break;
        default:
          break;
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
      nome: nome,
      sobrenome: sobrenome,
      telefoneCelular: _telefoneCelular,
      telefoneFixo: _telefoneFixo,
      especialidadesIds: especialidadesIds
    );
  }

  void adicionarTecnico() async {
    TecnicoService tecnicoService = TecnicoService();
    Tecnico tecnico = includeData();
    dynamic body = await tecnicoService.create(tecnico);

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
        title: const Text("Novo Técnico"),
        centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
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
                    mask: "(##) #####-####",
                    errorMessage: _errorMessage,
                    maxLength: 15,
                    controller: telefoneCelularController,
                    validation: validationTelefoneCelular,
                    type: TextInputType.phone,
                  ),
                  CustomMaskField(
                    hint: "(99) 99999-9999",
                    label: "Telefone Fixo",
                    mask: "(##) #####-####",
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
                        onPressed: adicionarTecnico,
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
        )
      )
    );
  }
}
