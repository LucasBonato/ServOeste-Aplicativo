import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';

class TableTecnicosModal extends StatefulWidget {
  final List<Tecnico> tecnicos;

  const TableTecnicosModal({super.key, required this.tecnicos});

  @override
  TableTecnicosModalState createState() => TableTecnicosModalState();
}

class TableTecnicosModalState extends State<TableTecnicosModal> {
  late List<PlutoColumnGroup> _columnGroups;
  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

  @override
  void initState() {
    super.initState();

    final List<DateTime> validDates = _getNextValidDates();

    final dateFields = validDates.map((date) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString().padLeft(2, '0');
      return '$day-$month-$year';
    }).toList();

    _columns = [
      PlutoColumn(
        title: 'Técnicos',
        field: 'tecnico',
        type: PlutoColumnType.text(),
        frozen: PlutoColumnFrozen.start,
        minWidth: 100,
        width: 150,
        enableEditingMode: false,
      ),
      ...dateFields.expand((field) => [
            PlutoColumn(
              title: 'M',
              field: '$field-M',
              type: PlutoColumnType.text(),
              minWidth: 80,
              width: 100,
              enableEditingMode: false,
            ),
            PlutoColumn(
              title: 'T',
              field: '$field-T',
              type: PlutoColumnType.text(),
              minWidth: 80,
              width: 100,
              enableEditingMode: false,
            ),
          ]),
    ];

    _columnGroups = [
      PlutoColumnGroup(
        title: 'Técnicos',
        fields: ['tecnico'],
        expandedColumn: true,
      ),
      ...dateFields.map(
        (field) => PlutoColumnGroup(
          title: field.replaceAll('-', '/'),
          fields: ['$field-M', '$field-T'],
        ),
      ),
    ];

    _rows = widget.tecnicos.map((tecnico) {
      final nomeComposto =
          "${tecnico.nome} ${getCompostName(tecnico.sobrenome ?? '')}";

      final Map<String, PlutoCell> dateFieldsMap = {
        for (var field in dateFields) ...{
          '$field-M':
              PlutoCell(value: tecnico.disponibilidade?['$field-M'] ?? ''),
          '$field-T':
              PlutoCell(value: tecnico.disponibilidade?['$field-T'] ?? ''),
        }
      };

      return PlutoRow(
        cells: {
          'tecnico': PlutoCell(value: nomeComposto),
          ...dateFieldsMap,
        },
      );
    }).toList();
  }

  List<DateTime> _getNextValidDates() {
    final List<DateTime> dates = [];
    DateTime currentDate = DateTime.now();

    while (dates.length < 3) {
      if (currentDate.weekday != DateTime.sunday) {
        dates.add(currentDate);
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dates;
  }

  String getCompostName(String sobrenome) {
    List<String> compostName = sobrenome.split(' ');

    if (compostName.isNotEmpty) {
      if (compostName.first.length <= 3 && compostName.length > 1) {
        return compostName[1];
      }
      return compostName.first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    bool isMediumScreen = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    double dialogWidth = isMediumScreen
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width * 0.65;

    double getFontSize(double min, double preferred, double max) {
      return (MediaQuery.of(context).size.width / 100).clamp(min, max);
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: dialogWidth,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Text(
              'Disponibilidade dos Técnicos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PlutoGrid(
                columns: _columns,
                rows: _rows,
                columnGroups: _columnGroups,
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    gridBorderColor: Colors.grey,
                    cellTextStyle: TextStyle(
                      fontSize: getFontSize(15, 16, 17),
                    ),
                    columnTextStyle: TextStyle(
                      fontSize: getFontSize(15, 16, 17),
                    ),
                  ),
                ),
                onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                  final tecnico = event.row.cells['tecnico']?.value as String?;
                  if (tecnico == null) {
                    Logger().e('Erro: Nome do técnico não encontrado!');
                    return;
                  }

                  final cellField = event.cell.column.field;

                  if (cellField == 'tecnico') {
                    Logger().w(
                        'Aviso: A coluna "Técnicos" foi selecionada. Nenhuma ação necessária.');
                    return;
                  }

                  final match = RegExp(r'^(\d{2}-\d{2}-\d{4})-(M|T)$')
                      .firstMatch(cellField);
                  if (match == null) {
                    Logger().e(
                        'Erro: Formato inválido no campo selecionado ($cellField)!');
                    return;
                  }

                  final dataSelecionada = match.group(1);
                  final horarioSelecionado = match.group(2);

                  final horarioConvertido =
                      horarioSelecionado == 'M' ? 'Manhã' : 'Tarde';

                  final cellValue = event.cell.value;

                  final tecnicoData = widget.tecnicos.firstWhere(
                    (tec) {
                      final nomeComposto =
                          "${tec.nome} ${getCompostName(tec.sobrenome ?? '')}";
                      return nomeComposto == tecnico;
                    },
                    orElse: () =>
                        Tecnico(nome: '', sobrenome: '', disponibilidade: {}),
                  );

                  if (tecnicoData.nome!.isEmpty) {
                    Logger().e('Erro: Técnico não encontrado na lista!');
                    return;
                  }

                  final extraInfo = tecnicoData.disponibilidade?[cellField] ??
                      'Sem informação';

                  final nomeTecnico =
                      '${tecnicoData.nome} ${tecnicoData.sobrenome ?? ''}';

                  Logger().i(
                    'Técnico: $nomeTecnico, '
                    'Data: $dataSelecionada, '
                    'Horário: $horarioConvertido, '
                    'Valor: $cellValue, '
                    'Informação extra: $extraInfo',
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique duas vezes em um dos números para puxar as informações do Técnico para o formulário',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
