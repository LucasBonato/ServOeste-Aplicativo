import 'package:flutter/material.dart';
import 'package:serv_oeste/src/models/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico_disponivel.dart';
import 'package:serv_oeste/src/services/servico_service.dart';
import 'package:serv_oeste/src/services/tecnico_service.dart';
import 'package:serv_oeste/src/util/constants.dart';
import 'package:serv_oeste/src/widgets/date_picker.dart';
import 'package:serv_oeste/src/widgets/dropdown_field.dart';
import 'package:serv_oeste/src/widgets/search_dropdown_field.dart';

class CreateServico extends StatefulWidget {
  const CreateServico({super.key});

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico>{
  late TextEditingController _equipamentoController, _marcaController, _filialController, _dataAtendimentoPrevistaController, _horarioPrevistoController, _tecnicoController;
  bool equipamentoValidation = false, marcaValidation = false, filialValidation = false, dataAtendimentoPrevistaValidation = false, horarioPrevistoValidation = false, tecnicoValidation = false;
  bool isTecnicosLoading = true;
  final String _errorMessage = "";
  List<String> _dropdownValuesNomes = [];
  List<Tecnico>? _listTecnicos = [];
  List<TecnicoDisponivel> _tecnicos = [];
  int? _idTecnicoSelected;
  String? _nomeEquipamento;
  late int dayOfTheWeek;

  @override
  void initState() {
    super.initState();
    _equipamentoController = TextEditingController();
    _marcaController = TextEditingController();
    _filialController = TextEditingController();
    _dataAtendimentoPrevistaController = TextEditingController();
    _horarioPrevistoController = TextEditingController();
    _tecnicoController = TextEditingController();

    dayOfTheWeek = DateTime.now().weekday;
  }

  @override
  void dispose() {
    _equipamentoController.dispose();
    _marcaController.dispose();
    _filialController.dispose();
    _dataAtendimentoPrevistaController.dispose();
    _horarioPrevistoController.dispose();
    _tecnicoController.dispose();
    super.dispose();
  }

  void getNomesTecnicos(String nome) async{
    _idTecnicoSelected = null;
    List<Tecnico>? tecnicos = await TecnicoService().getByIdNomesituacao(null, nome, null);
    if(tecnicos == null) return;
    List<String> nomes = [];
    for (int i = 0; i < tecnicos.length && i < 5; i++) {
      nomes.add("${tecnicos[i].nome!} ${tecnicos[i].sobrenome!}");
    }
    if(_dropdownValuesNomes != nomes) {
      setState(() {
        _listTecnicos = tecnicos;
        _dropdownValuesNomes = nomes;
      });
    }
  }

  void getTecnicosDisponiveis() async {
    ServicoService servicoService = ServicoService();
    List<TecnicoDisponivel> tecnicos = await servicoService.getTecnicosDisponiveis(_nomeEquipamento?? "Outros");
    setState(() {
      _tecnicos = tecnicos;
      isTecnicosLoading = false;
    });
  }

  void getIdTecnico(String nome) {
    for(Tecnico tecnico in _listTecnicos!) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          CustomSearchDropDown(
            label: "Equipamento",
            maxLength: 80,
            hide: true,
            errorMessage: _errorMessage,
            dropdownValues: Constants.equipamentos,
            onChanged: (equipamento) => getNomeEquipamento(equipamento),
            onSelected: (equipamento) => getNomeEquipamento(equipamento),
            validation: equipamentoValidation,
            controller: _equipamentoController
          ),
          CustomSearchDropDown(
            label: "Marca",
            maxLength: 40,
            hide: true,
            errorMessage: _errorMessage,
            dropdownValues: Constants.marcas,
            onChanged: (value) {},
            validation: marcaValidation,
            controller: _marcaController
          ),
          CustomDropdownField(
            label: "Filial",
            dropdownValues: Constants.filiais,
            controller: _filialController
          ),
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
          CustomDropdownField(
            label: "Horário Previsto",
            dropdownValues: Constants.dataAtendimento,
            controller: _horarioPrevistoController,
          ),
          CustomSearchDropDown(
            label: "Técnico",
            hide: true,
            errorMessage: _errorMessage,
            maxLength: 40,
            dropdownValues: _dropdownValuesNomes,
            onChanged: (nome) => getNomesTecnicos(nome),
            onSelected: (nome) => getIdTecnico(nome),
            validation: tecnicoValidation,
            controller: _tecnicoController
          ),
          TextButton(
            onPressed: (_idTecnicoSelected != null && _nomeEquipamento != null) ? () => _showDialog(context) : () => {},
            style: TextButton.styleFrom(
              backgroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null) ? Colors.blueAccent : Colors.grey,
              foregroundColor: (_idTecnicoSelected != null && _nomeEquipamento != null) ? Colors.white : Colors.black26,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.175, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              )
            ),
            child: const Text("Verificar disponibilidade", style: TextStyle(fontSize: 20))
          )
          ],
        ),
      ),
    );
  }

  TextStyle textStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

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

    Table tableWithData = Table(
      columnWidths: const <int, TableColumnWidth> {
        0: IntrinsicColumnWidth(flex: 2)
      },
    );

    List<TableRow> tecnicosDisponiveis = [];
    for (TecnicoDisponivel tecnico in _tecnicos) {
      tecnicosDisponiveis.add(
        TableRow(
          children: [
            TableCell(
              child: Text(tecnico.nome!, style: textStyle)
            ),
            TableCell(
              child: Text("")
            ),
            TableCell(
              child: Text("")
            ),
            TableCell(
              child: Text("")
            ),
            TableCell(
              child: Text("")
            ),
            TableCell(
              child: Text("")
            ),
            TableCell(
              child: Text("")
            ),
          ]
        )
      );
    }
    return tableWithData;
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
            ],
          ),
        ),
      )
    );
  }
}
