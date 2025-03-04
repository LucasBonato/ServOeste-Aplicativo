import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';

class TableTecnicosModal extends StatefulWidget {
  final int especialidadeId;
  final void Function(String nome, String data, String periodo, int id) setValuesAvailabilityTechnicianTable;

  const TableTecnicosModal({super.key, required this.especialidadeId, required this.setValuesAvailabilityTechnicianTable});

  @override
  TableTecnicosModalState createState() => TableTecnicosModalState();
}

class TableTecnicosModalState extends State<TableTecnicosModal> {
  late final TecnicoBloc _tecnicoBloc;
  late final List<String> dateFields;
  late List<PlutoColumnGroup> _columnGroups;
  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();

    _tecnicoBloc.add(TecnicoAvailabilitySearchEvent(idEspecialidade: widget.especialidadeId));

    dateFields = _getNextValidDates().map((date) {
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
      ...dateFields.expand(
        (field) => [
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
        ],
      ),
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
  }

  List<DateTime> _getNextValidDates() {
    final DateTime currentDate = DateTime.now();
    final List<DateTime> dates = [];

    for (int i = 0; i < 7; i++) {
      final DateTime potentialDate = currentDate.add(Duration(days: i));
      if (potentialDate.weekday != DateTime.sunday) {
        dates.add(potentialDate);
        if (dates.length == 3) break;
      }
    }

    return dates;
  }

  String getCompostName(String? sobrenome) {
    List<String> compostName = sobrenome!.split(' ');

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
    double dialogWidth = MediaQuery.of(context).size.width;

    double getFontSize(double min, double preferred, double max) {
      return (MediaQuery.of(context).size.width / 100).clamp(min, max);
    }

    return BlocBuilder<TecnicoBloc, TecnicoState>(
      bloc: _tecnicoBloc,
      builder: (context, state) {
        if (state is TecnicoSearchAvailabilitySuccessState) {
          if (state.tecnicosDisponiveis == null || state.tecnicosDisponiveis!.isEmpty) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: dialogWidth,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: Text(
                    'Nenhum técnico ocupado.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          state.tecnicosDisponiveis?.sort((tecnico1, tecnico2) => (tecnico1.quantidadeTotalServicos! > tecnico2.quantidadeTotalServicos!) ? 0 : 1);

          Logger().e(state.tecnicosDisponiveis);

          _rows = state.tecnicosDisponiveis!.map((tecnico) {
            final DateFormat formatter = DateFormat('dd-MM-yyyy');

            final Map<String, PlutoCell> dateFieldsMap = {
              for (String date in dateFields) ...{
                '$date-M': PlutoCell(value: '0'),
                '$date-T': PlutoCell(value: '0'),
              }
            };

            if (tecnico.disponibilidades != null) {
              for (var disponibilidade in tecnico.disponibilidades!) {
                final String formattedDate = formatter.format(disponibilidade.data!);
                final String key = '$formattedDate-${disponibilidade.periodo == "manha" ? "M" : "T"}';
                if (dateFieldsMap.containsKey(key)) {
                  dateFieldsMap[key] = PlutoCell(value: disponibilidade.quantidadeServicos.toString());
                }
              }
            }

            return PlutoRow(
              cells: {
                'id': PlutoCell(value: tecnico.id),
                'tecnico': PlutoCell(value: tecnico.nome),
                ...dateFieldsMap,
              },
            );
          }).toList();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: dialogWidth,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      'Disponibilidade dos Técnicos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 10,
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
                      onRowDoubleTap: _handleRowDoubleTap,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Clique duas vezes em um dos números para puxar as informações do Técnico para o formulário',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is TecnicoErrorState) {
          return Center(child: Text('Erro ao carregar as disponibilidades.'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _handleRowDoubleTap(PlutoGridOnRowDoubleTapEvent event) {
    final String? tecnicoNome = event.row.cells['tecnico']?.value as String?;
    final int? tecnicoId = event.row.cells['id']?.value as int?;
    final String cellField = event.cell.column.field;

    if (cellField == 'tecnico') {
      Logger().w('Aviso: A coluna "Técnicos" foi selecionada. Nenhuma ação necessária.');
      return;
    }

    final match = RegExp(r'^(\d{2}-\d{2}-\d{4})-(M|T)$').firstMatch(cellField);
    if (match == null) {
      Logger().e('Erro: Formato inválido no campo selecionado ($cellField)!');
      return;
    }

    final dataSelecionada = match.group(1)?.replaceAll("-", "/");
    final horarioSelecionado = match.group(2);
    final periodo = horarioSelecionado == 'M' ? 'Manhã' : 'Tarde';

    widget.setValuesAvailabilityTechnicianTable(tecnicoNome!, dataSelecionada!, periodo, tecnicoId!);

    Navigator.pop(context);
  }
}
