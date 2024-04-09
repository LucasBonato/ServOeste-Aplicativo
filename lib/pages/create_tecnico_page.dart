import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

class CreateTecnico extends StatefulWidget {
  final VoidCallback onIconPressed;

  const CreateTecnico({super.key, required this.onIconPressed});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  late TextEditingController nomeController;
  late TextEditingController telefoneCelularController;
  late TextEditingController telefoneFixoController;
  bool isCheckedAdega = false;
  bool isCheckedCooler = false;
  bool isCheckedLavaLouca = false;
  bool isCheckedPurificador = false;
  bool isCheckedBebedouro = false;
  bool isCheckedFrigobar = false;
  bool isCheckedLavaRoupa = false;
  bool isCheckedSecadora = false;
  bool isCheckedClimatizador = false;
  bool isCheckedGeladeira = false;
  bool isCheckedMicroondas = false;
  bool isCheckedOutros = false;

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

  void adicionarNovoTecnico(){
    if(telefoneCelularController.text.length != 15 && telefoneFixoController.text.length != 15) return;
    String telefoneCelular = transformarMask(telefoneCelularController.text);
    String telefoneFixo = transformarMask(telefoneFixoController.text);
    if(telefoneCelular.length == 11 && telefoneFixo.length == 11){
      print("Dois Telefones");
    } else if(telefoneCelular.length == 11 && telefoneFixo.length != 11){
      print("Só o Celular");
    }else if(telefoneCelular.length != 11 && telefoneFixo.length == 11){
      print("Só o Fixo");
    }
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
                      decoration: const InputDecoration(
                        hintText: "Nome...",
                        labelText: "Nome",
                        isDense: true,
                        fillColor: Color(0xFFF1F4F8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: MaskedTextField(
                      controller: telefoneCelularController,
                      mask: "(##) #####-####",
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "(99) 99999-9999",
                        labelText: "Telefone Celular",
                        isDense: true,
                        fillColor: Color(0xFFF1F4F8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: MaskedTextField(
                      controller: telefoneFixoController,
                      mask: "(##) #####-####",
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "(99) 99999-9999",
                        labelText: "Telefone Fixo",
                        isDense: true,
                        fillColor: Color(0xFFF1F4F8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
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
                      const Text('Selecione os conhecimentos do Técnico:'),
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),

                        child: TextButton(
                          onPressed: adicionarNovoTecnico,
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

