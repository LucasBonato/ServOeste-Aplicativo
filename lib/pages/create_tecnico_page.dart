import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';
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

  bool isCheckedAdega = false,
      isCheckedCooler = false,
      isCheckedLavaLouca = false,
      isCheckedPurificador = false,
      isCheckedBebedouro = false,
      isCheckedFrigobar = false,
      isCheckedLavaRoupa = false,
      isCheckedSecadora = false,
      isCheckedClimatizador = false,
      isCheckedGeladeira = false,
      isCheckedMicroondas = false,
      isCheckedOutros = false;

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

  void setErrorNome(String errorMessage){
    setState(() {
      _errorMessage = errorMessage;
      validationNome = true;
    });
  }
  void setErrorTelefoneCelular(String errorMessage){
    setState(() {
      _errorMessage = errorMessage;
      validationTelefoneCelular = true;
    });
  }
  void setErrorTelefoneFixo(String errorMessage){
    setState(() {
      _errorMessage = errorMessage;
      validationTelefoneFixo = true;
    });
  }
  void setErrorCheckBox(String errorMessage){
    setState(() {
      validationTelefoneCelular = false;
      validationTelefoneFixo = false;
      _errorMessage = errorMessage;
      validationCheckBoxes = true;
    });
  }

  bool verifyCampoNome(){
    if(nomeController.text == "") {
      setErrorNome("O campo nome não pode ser vazio!");
      return false;
    }

    List<String> nomeSobrenome = nomeController.text.split(" ");

    if(nomeSobrenome.length <= 1) {
      setErrorNome("Digite Nome e Sobrenome!");
      return false;
    }
    for(String nome in nomeSobrenome){
      if(nome.length <= 2) {
        setErrorNome("Nome o Sobrenome precisa ter no mínimo 2 caracteres!");
        return false;
      }
    }
    return true;
  }
  bool verifyCamposTelefones(){
    String telefoneCelular = transformarMask(telefoneCelularController.text);
    String telefoneFixo = transformarMask(telefoneFixoController.text);
    if(telefoneCelular.length != 11 && telefoneFixo.length != 11) {
      setErrorTelefoneCelular("Insira um Telefone válido!");
      setErrorTelefoneFixo("Insira um Telefone válido!");
      return false;
    }
    if(telefoneCelular.length == 11 && telefoneFixo.length == 11){
      _telefoneCelular = telefoneCelular;
      _telefoneFixo = telefoneFixo;
    } else if(telefoneCelular.length == 11 && telefoneFixo.length != 11){
      _telefoneCelular = telefoneCelular;
    } else if(telefoneCelular.length != 11 && telefoneFixo.length == 11){
      _telefoneFixo = telefoneFixo;
    }
    return true;
  }
  bool verifyCamposCheck(){
    List<bool> checkers = addCheckerInAList();

    if(checkers.where((element) => element == true).isEmpty) {
      setErrorCheckBox("Todos falsos");
      return false;
    }
    setState(() {
      validationCheckBoxes = false;
    });
    return true;
  }

  List<bool> addCheckerInAList() {
    return [
      isCheckedAdega,
      isCheckedBebedouro,
      isCheckedClimatizador,
      isCheckedCooler,
      isCheckedFrigobar,
      isCheckedGeladeira,
      isCheckedLavaLouca,
      isCheckedLavaRoupa,
      isCheckedMicroondas,
      isCheckedPurificador,
      isCheckedSecadora,
      isCheckedOutros
    ];
  }

  Tecnico includeData() {
    List<String> nomes = nomeController.text.split(" ");
    String nome = nomes.first;
    String sobrenome = "";
    for(int i = 1; i < nomes.length; i++){
      sobrenome += "${nomes[i]} ";
    }
    sobrenome = sobrenome.trim();

    List<int> especialidadesIds = [];
    for(int i = 0; i < addCheckerInAList().length; i++){
      if(addCheckerInAList()[i] == false) continue;
      especialidadesIds.add(++i);
    }

    return Tecnico(
      nome: nome,
      sobrenome: sobrenome,
      telefoneCelular: _telefoneCelular,
      telefoneFixo: _telefoneFixo,
      especialidadesIds: especialidadesIds
    );
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: MaskedTextField(
                      controller: nomeController,
                      maxLength: 40,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        errorText: (validationNome) ? _errorMessage : null,
                        hintText: "Nome...",
                        labelText: "Nome",
                        isDense: true,
                        fillColor: const Color(0xFFF1F4F8),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () => {
                        setState(() {
                          validationNome = false;
                        })
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: MaskedTextField(
                      controller: telefoneCelularController,
                      mask: "(##) #####-####",
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        errorText: (validationTelefoneCelular) ? _errorMessage : null,
                        hintText: "(99) 99999-9999",
                        labelText: "Telefone Celular",
                        isDense: true,
                        fillColor: const Color(0xFFF1F4F8),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () => {
                        setState(() {
                          validationTelefoneCelular = false;
                        })
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: MaskedTextField(
                      controller: telefoneFixoController,
                      mask: "(##) #####-####",
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        errorText: (validationTelefoneFixo) ? _errorMessage : null,
                        hintText: "(99) 99999-9999",
                        labelText: "Telefone Fixo",
                        isDense: true,
                        fillColor: const Color(0xFFF1F4F8),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () => {
                        setState(() {
                          validationTelefoneFixo = false;
                        })
                      },
                    ),
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
                      const Column(
                        children: [
                          Text('Selecione os conhecimentos do Técnico:', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text('Adega'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                        value: isCheckedAdega,
                                        activeColor: Colors.blue,
                                        side: const BorderSide(
                                          width: 2,
                                          color: Colors.blueAccent,
                                        ),
                                        onChanged: (value) => {
                                          setState(() {
                                            isCheckedAdega = !isCheckedAdega;
                                          })
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Cooler'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedCooler,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedCooler = !isCheckedCooler;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Lava Louça'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedLavaLouca,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedLavaLouca = !isCheckedLavaLouca;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Purificador'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedPurificador,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedPurificador = !isCheckedPurificador;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text('Bebedouro'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedBebedouro,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedBebedouro = !isCheckedBebedouro;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Frigobar'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedFrigobar,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedFrigobar = !isCheckedFrigobar;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Lava Roupa'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedLavaRoupa,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedLavaRoupa = !isCheckedLavaRoupa;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Secadora'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedSecadora,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedSecadora = !isCheckedSecadora;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text('Climatizador'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedClimatizador,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedClimatizador = !isCheckedClimatizador;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Geladeira'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedGeladeira,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedGeladeira = !isCheckedGeladeira;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Microondas'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedMicroondas,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedMicroondas = !isCheckedMicroondas;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Outros'),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                          value: isCheckedOutros,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => {
                                            setState(() {
                                              isCheckedOutros = !isCheckedOutros;
                                            })
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(validationCheckBoxes ? _errorMessage : "", style: const TextStyle(color: Colors.red))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),

                        child: TextButton(
                          onPressed: () async {
                            if(verifyCampoNome() && verifyCamposTelefones() && verifyCamposCheck()){
                              TecnicoService tecnicoService = TecnicoService();
                              Tecnico tecnico = includeData();
                              if(await tecnicoService.create(tecnico)){
                                widget.onIconPressed();
                              }
                            }
                          },
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
