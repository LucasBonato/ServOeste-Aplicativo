import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/screens/servico/create_servico.dart';

class TableTecnicosModal extends StatefulWidget {
  final int especialidadeId;
  final List<Tecnico> tecnicos;

  const TableTecnicosModal(
      {super.key, required this.especialidadeId, required this.tecnicos});

  @override
  TableTecnicosModalState createState() => TableTecnicosModalState();
}

class TableTecnicosModalState extends State<TableTecnicosModal> {
  late final TecnicoBloc _tecnicoBloc;
  late final List<String> dateFields;
  late List<PlutoColumnGroup> _columnGroups;
  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;
  late ServicoForm _servicoForm;

  @override
  void initState() {
    super.initState();
    _tecnicoBloc = context.read<TecnicoBloc>();

    _tecnicoBloc.add(TecnicoAvailabilitySearchEvent(
        idEspecialidade: widget.especialidadeId));

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
  }

  List<DateTime> _getNextValidDates() {
    //TODO - Existem jeitos melhores de fazer isso aqui, cuidado com muitos loops na aplicação
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
    double dialogWidth = MediaQuery.of(context).size.width * 0.85;

    double getFontSize(double min, double preferred, double max) {
      return (MediaQuery.of(context).size.width / 100).clamp(min, max);
    }

    return BlocBuilder<TecnicoBloc, TecnicoState>(
      bloc: _tecnicoBloc,
      builder: (context, state) {
        if (state is TecnicoLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is TecnicoSearchAvailabilitySuccessState) {
          if (state.tecnicosDisponiveis == null ||
              state.tecnicosDisponiveis!.isEmpty) {
            return SizedBox();
          }

          _rows = state.tecnicosDisponiveis!.map((tecnico) {
            final DateFormat formatter = DateFormat('dd-MM-yyyy');

            final Map<String, PlutoCell> dateFieldsMap = {
              for (var date in dateFields) ...{
                '$date-M': PlutoCell(value: '0'),
                '$date-T': PlutoCell(value: '0'),
              }
            };

            print(state.tecnicosDisponiveis!
                .map((tecnico) => tecnico.id)
                .join(', '));

            if (tecnico.disponibilidades != null) {
              for (var disponibilidade in tecnico.disponibilidades!) {
                final String formattedDate =
                    formatter.format(disponibilidade.data!);
                final String key =
                    '$formattedDate-${disponibilidade.periodo == "manha" ? "M" : "T"}';
                if (dateFieldsMap.containsKey(key)) {
                  dateFieldsMap[key] = PlutoCell(
                      value: disponibilidade.quantidadeServicos.toString());
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    final tecnicoNome = event.row.cells['tecnico']?.value as String?;
    final tecnicoId = event.row.cells['id']?.value as int?;
    final cellField = event.cell.column.field;

    if (cellField == 'tecnico') {
      Logger().w(
          'Aviso: A coluna "Técnicos" foi selecionada. Nenhuma ação necessária.');
      return;
    }

    final match = RegExp(r'^(\d{2}-\d{2}-\d{4})-(M|T)$').firstMatch(cellField);
    if (match == null) {
      Logger().e('Erro: Formato inválido no campo selecionado ($cellField)!');
      return;
    }

    final dataSelecionada = match.group(1);
    final horarioSelecionado = match.group(2);
    final horarioConvertido = horarioSelecionado == 'M' ? 'Manhã' : 'Tarde';

    // _servicoForm.setNomeTecnico(tecnico);
    // _servicoForm.setDataPrevista(dataSelecionada);
    // _servicoForm.setHorario(horarioConvertido);

    CreateServico.setValuesAvailabilityTechnicianTable(_servicoForm,
        tecnicoNome!, dataSelecionada!, horarioConvertido, tecnicoId);

    Navigator.pop(context);
  }
}
