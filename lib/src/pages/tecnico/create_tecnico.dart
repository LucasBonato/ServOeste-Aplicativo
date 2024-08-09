import 'package:flutter/material.dart';
import 'package:serv_oeste/src/widgets/mask_field.dart';
import 'package:serv_oeste/src/models/tecnico.dart';
import 'package:serv_oeste/src/services/tecnico_service.dart';

class CreateTecnico extends StatefulWidget {
  const CreateTecnico({super.key});

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
  }
  @override
  void dispose() {
    nomeController.dispose();
    telefoneCelularController.dispose();
    telefoneFixoController.dispose();
    super.dispose();
  }

  String transformarMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
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
      nome: nome,
      sobrenome: sobrenome,
      telefoneCelular: _telefoneCelular,
      telefoneFixo: _telefoneFixo,
      especialidadesIds: especialidadesIds
    );
  }

  void adicionarTecnico(BuildContext context) async {
    TecnicoService tecnicoService = TecnicoService();
    Tecnico tecnico = includeData();
    dynamic body = await tecnicoService.create(tecnico);

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
                    //rowCheckersMap(),
                    Container(
                      child: gridCheckersMap()
                    ),
                    Text(validationCheckBoxes ? _errorMessage : "", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                      child: TextButton(
                        onPressed: () => adicionarTecnico(context),
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
