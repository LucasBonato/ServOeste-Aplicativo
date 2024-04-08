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
  bool isChecked = false;

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

  void changeValueCheckBox(bool? value){
    setState(() {
      value = !value!;
    });
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
                                  Text('Adega'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Cooler'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Lava Louça'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Purificador'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
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
                                  Text('Bebedouro'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Frigobar'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Lava Roupa'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Secadora'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
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
                                  Text('Climatizador'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Geladeira'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Microondas'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Outros'),
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
                                          value: isChecked,
                                          activeColor: Colors.blue,
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.blueAccent,
                                          ),
                                          onChanged: (value) => changeValueCheckBox(isChecked)
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

