import 'package:flutter/material.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';

import '../../components/mask_field.dart';

class CreateServico extends StatefulWidget {
  const CreateServico({super.key});

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico>{
  final List<String> _dropdownValuesNomes = [];
  late TextEditingController nomeController,
      telefoneFixoController,
      telefoneCelularController,
      cepController,
      enderecoController,
      bairroController,
      municipioController;
  String _errorMessage = "",
      _telefoneCelular = "",
      _telefoneFixo = "",
      _sobrenome = "";
  bool
  validationNome = false,
      validationTelefoneCelular = false,
      validationTelefoneFixo = false,
      validationCep = false,
      validationEndereco = false,
      validationBairro = false,
      validationMunicipio = false;

  late TextEditingController _equipamentoController,
      _marcaController,
      _filialController,
      _dataAtendimentoPrevistaController,
      _horarioPrevistoController,
      _tecnicoController,
      _descricaoController;
  late int dayOfTheWeek;
  bool equipamentoValidation = false,
      marcaValidation = false,
      filialValidation = false,
      dataAtendimentoPrevistaValidation = false,
      horarioPrevistoValidation = false,
      tecnicoValidation = false,
      descricaoValidation = false;
  bool isTecnicosLoading = true;
  final List<String> _dropdownValuesNames = [];
  final List<Tecnico> _listTecnicos = [];
  final List<TecnicoDisponivel> _tecnicos = [];
  int? _idTecnicoSelected;
  String? _nomeEquipamento;
  TextStyle textStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
    telefoneFixoController = TextEditingController();
    telefoneCelularController = TextEditingController();
    cepController = TextEditingController();
    enderecoController = TextEditingController();
    bairroController = TextEditingController();
    municipioController = TextEditingController();
    _equipamentoController = TextEditingController();
    _marcaController = TextEditingController();
    _filialController = TextEditingController();
    _dataAtendimentoPrevistaController = TextEditingController();
    _horarioPrevistoController = TextEditingController();
    _tecnicoController = TextEditingController();
    _descricaoController = TextEditingController();

    dayOfTheWeek = DateTime.now().weekday;
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneFixoController.dispose();
    telefoneCelularController.dispose();
    cepController.dispose();
    enderecoController.dispose();
    bairroController.dispose();
    municipioController.dispose();
    _equipamentoController.dispose();
    _marcaController.dispose();
    _filialController.dispose();
    _dataAtendimentoPrevistaController.dispose();
    _horarioPrevistoController.dispose();
    _tecnicoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void setError(int erro, String errorMessage){
    setErrorNome(){
      validationNome = true;
    }
    setErrorTelefoneCelular(){
      validationTelefoneCelular = true;
    }
    setErrorTelefoneFixo(){
      validationTelefoneFixo = true;
    }
    setErrorTelefones(){
      setErrorTelefoneCelular();
      setErrorTelefoneFixo();
    }
    setErrorCep(){
      validationCep = true;
    }
    setErrorEndereco(){
      validationEndereco = true;
    }
    setErrorMunicipio(){
      validationMunicipio = true;
    }
    setErrorBairro(){
      validationBairro = true;
    }
    setErrorEquipamento() {
      equipamentoValidation = true;
    }
    setErrorMarca() {
      marcaValidation = true;
    }
    setErrorFilial() {
      filialValidation = true;
    }
    setErrorDataAtendimento() {
      dataAtendimentoPrevistaValidation = true;
    }
    setErrorHorarioPrevisto() {
      horarioPrevistoValidation = true;
    }
    setErrorTecnico() {
      tecnicoValidation = true;
    }
    setErrorDescricao() {
      descricaoValidation = true;
    }
    setState(() {
      validationNome = false;
      validationTelefoneCelular = false;
      validationTelefoneFixo = false;
      validationCep = false;
      validationEndereco = false;
      validationBairro = false;
      validationMunicipio = false;
      equipamentoValidation = false;
      marcaValidation = false;
      filialValidation = false;
      dataAtendimentoPrevistaValidation = false;
      horarioPrevistoValidation = false;
      tecnicoValidation = false;
      descricaoValidation = false;

      _errorMessage = "";
      switch(erro){
        case 1: setErrorNome(); break;
        case 2: setErrorTelefoneCelular(); break;
        case 3: setErrorTelefoneFixo(); break;
        case 4: setErrorTelefones(); break;
        case 5: setErrorCep(); break;
        case 6: setErrorEndereco(); break;
        case 7: setErrorBairro(); break;
        case 8: setErrorMunicipio(); break;
        case 9: setErrorEquipamento(); break;
        case 10: setErrorMarca(); break;
        case 11: setErrorFilial(); break;
        case 12: setErrorDataAtendimento(); break;
        case 13: setErrorHorarioPrevisto(); break;
        case 14: setErrorTecnico(); break;
        case 15: setErrorDescricao(); break;
      }
      _errorMessage = errorMessage;
    });
  }

  ClienteRequest includeDataCliente() {
    List<String> nomes = nomeController.text.split(" ");
    String nome = nomes.first;
    String sobrenome = "";
    for(int i = 1; i < nomes.length; i++){
      sobrenome += "${nomes[i]} ";
    }
    _sobrenome = sobrenome.trim();

    _telefoneCelular = transformarMask(telefoneCelularController.text);
    _telefoneFixo = transformarMask(telefoneFixoController.text);

    return ClienteRequest(
        nome: nome,
        sobrenome: _sobrenome,
        telefoneCelular: _telefoneCelular,
        telefoneFixo: _telefoneFixo,
        endereco: enderecoController.text,
        bairro: bairroController.text,
        municipio: municipioController.text
    );
  }

  String transformarMask(String telefone){
    if(telefone.length != 15) return "";
    return telefone.substring(1, 3) + telefone.substring(5, 10) + telefone.substring(11);
  }

  void getInformationsAboutCep(String? cep) async {
    // if(cep?.length != 9) return;
    // String? endereco = await ClienteService().getEndereco(cep!);
    // if(endereco != null) {
    //   List<String> camposSobreEndereco = endereco.split("|");
    //   enderecoController.text = camposSobreEndereco[0];
    //   bairroController.text = camposSobreEndereco[1];
    //   municipioController.text = camposSobreEndereco[2];
    //   return;
    // }
    // setError(5, "Endereço não\n encontrado");
  }

  void getNomesClientes(String nome) async{
    // List<Cliente>? clientes = await ClienteService().getByNome(nome);
    // if(clientes == null) return;
    // List<String> nomes = [];
    // for (int i = 0; i < clientes.length && i < 5; i++) {
    //   nomes.add(clientes[i].nome!);
    // }
    // if(_dropdownValuesNomes != nomes) {
    //   setState(() {
    //     _dropdownValuesNomes = nomes;
    //   });
    // }
  }



  void getNomesTecnicos(String nome) async{
    // _idTecnicoSelected = null;
    // List<Tecnico>? tecnicos = await TecnicoService().getByIdNomesituacao(null, nome, "Ativo");
    // if(tecnicos == null) return;
    // List<String> nomes = [];
    // for (int i = 0; i < tecnicos.length && i < 5; i++) {
    //   nomes.add("${tecnicos[i].nome!} ${tecnicos[i].sobrenome!}");
    // }
    // if(_dropdownValuesNames != nomes) {
    //   setState(() {
    //     _listTecnicos = tecnicos;
    //     _dropdownValuesNames = nomes;
    //   });
    // }
  }

  void getTecnicosDisponiveis() async {
    // ServicoService servicoService = ServicoService();
    // List<TecnicoDisponivel> tecnicos = await servicoService.getTecnicosDisponiveis();
    // setState(() {
    //   _tecnicos = tecnicos;
    //   isTecnicosLoading = false;
    // });
  }

  void getIdTecnico(String nome) {
    for(Tecnico tecnico in _listTecnicos) {
      if("${tecnico.nome!} ${tecnico.sobrenome!}" == _tecnicoController.text) {
        setState(() {
          _idTecnicoSelected = tecnico.id!;
        });
      }
    }
  }

  void getNomeEquipamento(String equipamento) {
    if(equipamento.isNotEmpty) {
      setState(() {
        _nomeEquipamento = (Constants.equipamentos.contains(equipamento)) ? equipamento : "Outros";
      });
    } else {
      setState(() {
        _nomeEquipamento = null;
      });
    }
  }

  void _cadastrarServico() async {

    ServicoRequest servico = ServicoRequest(
        idTecnico: _idTecnicoSelected!,
        equipamento: _nomeEquipamento!,
        marca: _marcaController.text,
        filial: _filialController.text,
        dataAtendimento: _dataAtendimentoPrevistaController.text,
        horarioPrevisto: _horarioPrevistoController.text.toLowerCase().replaceAll("ã", "a"),
        descricao: _descricaoController.text
    );
    ClienteRequest cliente = includeDataCliente();

    // dynamic body = await ServicoService().cadastrarServicoMaisCliente(servico, cliente);
    //
    // if(body == null && context.mounted) {
    //   Navigator.pop(context);
    //   return;
    // }
    // setError(body["idError"], body["message"]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Novo Serviço"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CustomSearchDropDown(
                      onChanged: (nome) => getNomesClientes(nome),
                      label: "Nome",
                      controller: nomeController,
                      maxLength: 40,
                      hide: true,
                      dropdownValues: _dropdownValuesNomes,
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
                  ),  // Telefone Celular
                  CustomMaskField(
                    hint: "(99) 99999-9999",
                    label: "Telefone Fixo",
                    mask: "(##) #####-####",
                    errorMessage: _errorMessage,
                    maxLength: 15,
                    controller: telefoneFixoController,
                    validation: validationTelefoneFixo,
                    type: TextInputType.phone,
                  ),  // Telefone Fixo
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: CustomMaskField(
                          hint: "00000-000",
                          label: "CEP",
                          mask: "#####-###",
                          errorMessage: _errorMessage,
                          maxLength: 9,
                          hide: true,
                          controller: cepController,
                          validation: validationCep,
                          type: TextInputType.number,
                          rightPadding: 4,
                          onChanged: (cep) => getInformationsAboutCep(cep),
                        ),
                      ),  // CEP
                      Expanded(
                        flex: 8,
                        child: CustomMaskField(
                          hint: "Rua...",
                          label: "Endereço, Número e Complemento",
                          mask: null,
                          errorMessage: _errorMessage,
                          maxLength: 255,
                          hide: true,
                          controller: enderecoController,
                          validation: validationEndereco,
                          type: TextInputType.text,
                          leftPadding: 4,
                        ),
                      ),  // Endereço
                    ],
                  ),
                  // CustomDropdownField(
                  //     label: "Município",
                  //     dropdownValues: Constants.municipios,
                  //     controller: municipioController
                  // ),
                  CustomMaskField(
                      hint: "Bairro...",
                      label: "Bairro",
                      mask: null,
                      errorMessage: _errorMessage,
                      maxLength: 255,
                      hide: true,
                      controller: bairroController,
                      validation: validationBairro,
                      type: TextInputType.text
                  ),  // Bairro

                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.032,
                      right: MediaQuery.of(context).size.width * 0.032,
                      bottom: 8
                    ),
                    child: const Divider(),
                  ),

                  CustomSearchDropDown(
                      label: "Equipamento",
                      maxLength: 80,
                      hide: true,
                      dropdownValues: Constants.equipamentos,
                      onChanged: (equipamento) => getNomeEquipamento(equipamento),
                      onSelected: (equipamento) => getNomeEquipamento(equipamento),
                      controller: _equipamentoController
                  ),
                  CustomSearchDropDown(
                      label: "Marca",
                      maxLength: 40,
                      hide: true,
                      dropdownValues: Constants.marcas,
                      onChanged: (value) {},
                      controller: _marcaController
                  ),
                  // CustomDropdownField(
                  //     label: "Filial",
                  //     dropdownValues: Constants.filiais,
                  //     controller: _filialController
                  // ),
                  CustomDatePicker(
                      label: "Data Atendimento Previsto",
                      hint: "",
                      mask: "##/##/####",
                      type: TextInputType.datetime,
                      maxLength: 10,
                      hide: true,
                      errorMessage: _errorMessage,
                      validation: dataAtendimentoPrevistaValidation,
                      controller: _dataAtendimentoPrevistaController
                  ),
                  // CustomDropdownField(
                  //   label: "Horário Previsto",
                  //   dropdownValues: Constants.dataAtendimento,
                  //   controller: _horarioPrevistoController,
                  // ),
                  CustomMaskField(
                      hint: "Descrição...",
                      label: "Descrição",
                      mask: null,
                      errorMessage: _errorMessage,
                      maxLength: 200,
                      maxLines: 5,
                      controller: _descricaoController,
                      type: TextInputType.text,
                      validation: descricaoValidation
                  ),
                  CustomSearchDropDown(
                      label: "Técnico",
                      hide: true,
                      maxLength: 40,
                      dropdownValues: _dropdownValuesNames,
                      onChanged: (nome) => getNomesTecnicos(nome),
                      onSelected: (nome) => getIdTecnico(nome),
                      controller: _tecnicoController
                  ),
                  Column(
                    children: [
                      TextButton(
                          onPressed: (_idTecnicoSelected != null && _nomeEquipamento != null) ? () => _showDialog(context) : () => {},
                          style: TextButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.80, 48),
                              backgroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null) ? Colors.blueAccent : Colors.grey,
                              foregroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null) ? Colors.white : Colors.black26,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              )
                          ),
                          child: const Text("Verificar disponibilidade", style: TextStyle(fontSize: 20))
                      ),
                      Divider(
                          height: MediaQuery.of(context).size.height * 0.01,
                          thickness: 0,
                          color: Colors.transparent
                      ),
                      TextButton(
                          onPressed: (_idTecnicoSelected != null && _nomeEquipamento != null && nomeController.text.isNotEmpty && (telefoneCelularController.text.isNotEmpty || telefoneFixoController.text.isNotEmpty) && enderecoController.text.isNotEmpty && municipioController.text.isNotEmpty && bairroController.text.isNotEmpty && _descricaoController.text.isNotEmpty) ? () => _cadastrarServico() : () => {},
                          style: TextButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.80, 48),
                              backgroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null && nomeController.text.isNotEmpty && (telefoneCelularController.text.isNotEmpty || telefoneFixoController.text.isNotEmpty) && enderecoController.text.isNotEmpty && municipioController.text.isNotEmpty && bairroController.text.isNotEmpty && _descricaoController.text.isNotEmpty) ? Colors.blueAccent : Colors.grey,
                              foregroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null && nomeController.text.isNotEmpty && (telefoneCelularController.text.isNotEmpty || telefoneFixoController.text.isNotEmpty) && enderecoController.text.isNotEmpty && municipioController.text.isNotEmpty && bairroController.text.isNotEmpty && _descricaoController.text.isNotEmpty) ? Colors.white : Colors.black26,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              )
                          ),
                          child: const Text("Cadastrar novo serviço", style: TextStyle(fontSize: 20))
                      ),
                    ],
                  )
                ],
              ),
          ),
        ),
    );
  }

  String dayOfTheWeekString(int day) {
    return switch (day) {
      1 || 7 => "Segunda",
      2 || 8 => "Terça",
      3 || 9 => "Quarta",
      4 => "Quinta",
      5 => "Sexta",
      6 => "Sábado",
      _ => "Domingo"
    };
  }

  Table _buildTableWithData()  {
    getTecnicosDisponiveis();

    if(_tecnicos.isEmpty) {
      return Table(
        border: TableBorder.all(
          style: BorderStyle.solid,
          width: 2,
          color: Colors.black
        ),
        children: [
          TableRow(
            children: [
              TableCell(child: Text("Nenhum técnico ocupado!", textAlign: TextAlign.center, style: textStyle))
            ]
          )
        ],
      );
    }

    return Table(
      columnWidths: const <int, TableColumnWidth> {
        0: FlexColumnWidth(2)
      },
      border: TableBorder.all(
          color: Colors.black,
          width: 2
      ),
      children: construirLinhasTecnicos(_tecnicos, dayOfTheWeek, 5),
    );
  }

  Map<String, int> calcularDias(int dayOfTheWeek, List<Disponibilidade> disponibilidades) {
    Map<String, int> dias = {
      "total": 0,
      "${dayOfTheWeekString(dayOfTheWeek)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek)}T": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 1)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 1)}T": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 2)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 2)}T": 0,
    };

    for (Disponibilidade disponibilidade in disponibilidades) {
      String key = "${dayOfTheWeekString(disponibilidade.dia!)}${disponibilidade.periodo!.substring(0, 1).toUpperCase()}";
      dias[key] = disponibilidade.quantidade!;
      dias["total"] = dias["total"]! + disponibilidade.quantidade!;
    }

    return dias;
  }

  List<TableRow> construirLinhasTecnicos(List<TecnicoDisponivel> tecnicos, int dayOfTheWeek, int quantidadeLimiteDeLinhas) {
    // Ordena os técnicos pelo total de quantidades, do maior para o menor
    tecnicos.sort((a, b) {
      int totalA = a.disponibilidades!.fold(0, (prev, element) => prev + element.quantidade!);
      int totalB = b.disponibilidades!.fold(0, (prev, element) => prev + element.quantidade!);
      return totalB.compareTo(totalA); // Maior para menor
    });

    List<TableRow> tecnicosDisponiveis = [];
    for (int i = 0; i < tecnicos.length && i < quantidadeLimiteDeLinhas; i++) {
      TecnicoDisponivel tecnico = tecnicos[i];
      Map<String, int> dias = calcularDias(dayOfTheWeek, tecnico.disponibilidades!);

      int id = tecnico.id!;
      String nome = tecnico.nome!;

      tecnicosDisponiveis.add(
        TableRow(
          children: [
            TableCell(
              child: Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 0, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek)}M"]}", style: textStyle, textAlign: TextAlign.center),
              ),
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 0, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 1, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 1)}M"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 1, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 1)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 2, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 2)}M"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationsOnTheFormFromTable(id, 2, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 2)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
          ],
        ),
      );
    }

    return tecnicosDisponiveis;
  }

  void _changeInformationsOnTheFormFromTable(int id, int daysToAdd, String nome) {
    String dataAtendimento = "${dataFormated(daysToAdd)}/${DateTime.now().year}";
    setState(() {
      _idTecnicoSelected = id;
      _tecnicoController.text = nome;
      _dataAtendimentoPrevistaController.text = dataAtendimento;
    });
    Navigator.pop(context);
  }

  String dataFormated(int daysToAdd) {
    DateTime diaAtual = DateTime.now();
    int addedDays = 0;

    if(dayOfTheWeek == DateTime.sunday) {
      diaAtual = diaAtual.add(const Duration(days: 1));
    }

    while (addedDays < daysToAdd) {
      diaAtual = diaAtual.add(const Duration(days: 1));
      if (diaAtual.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    String formattedDate = "${diaAtual.day.toString().padLeft(2, '0')}/${diaAtual.month.toString().padLeft(2, '0')}";
    return formattedDate;
  }
  
  Table _tableDias() {
    return Table(
      border: TableBorder.all(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        color: Colors.black,
        width: 2
      ),
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text("Técnicos", textAlign: TextAlign.center, style: textStyle)
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(0), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek), style: textStyle),
                ],
              )
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(1), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek + 1), style: textStyle),
                ],
              )
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(2), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek + 2), style: textStyle),
                ],
              )
            ),
          ]
        ),
      ],
    );
  }

  Future _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Container(
          margin: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height * .35,
          child: Column(
            children: [
              _tableDias(),
              Table(
                border: TableBorder.all(
                  color: Colors.black,
                  width: 2
                ),
                columnWidths: const <int, TableColumnWidth> {
                  0: IntrinsicColumnWidth(flex: 2)
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text("")
                      ),
                      TableCell(
                        child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                        child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                    ]
                  )
                ],
              ),
              _buildTableWithData(),
              const Text("Clique duas vezes em um dos números para puxar as informações do técnico para o formulário", textAlign: TextAlign.center, )
            ],
          ),
        ),
      )
    );
  }
}
