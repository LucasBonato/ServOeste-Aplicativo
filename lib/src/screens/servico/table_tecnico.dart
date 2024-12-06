import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TableTecnicosModal extends StatefulWidget {
  const TableTecnicosModal({super.key});

  @override
  State<TableTecnicosModal> createState() => _TableTecnicosModalState();
}

class _TableTecnicosModalState extends State<TableTecnicosModal> {
  late List<PlutoColumnGroup> _columnGroups;
  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

  @override
  void initState() {
    super.initState();

    _columns = [
      PlutoColumn(
        title: 'Técnicos',
        field: 'tecnico',
        type: PlutoColumnType.text(),
        frozen: PlutoColumnFrozen.start,
      ),
      PlutoColumn(
        title: 'M',
        field: '13-12-M',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'T',
        field: '13-12-T',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'M',
        field: '14-12-M',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'T',
        field: '14-12-T',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'M',
        field: '16-12-M',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'T',
        field: '16-12-T',
        type: PlutoColumnType.text(),
      ),
    ];

    _columnGroups = [
      PlutoColumnGroup(
          title: 'Técnicos', fields: ['tecnico'], expandedColumn: true),
      PlutoColumnGroup(title: '13/12/24', fields: ['13-12-M', '13-12-T']),
      PlutoColumnGroup(title: '14/12/24', fields: ['14-12-M', '14-12-T']),
      PlutoColumnGroup(title: '16/12/24', fields: ['16-12-M', '16-12-T']),
    ];

    // Simula os dados dos técnicos
    final List<Map<String, dynamic>> tecnicos = [
      {
        "tecnico": "Técnico 1",
        "13-12-M": "1",
        "13-12-T": "0",
        "14-12-M": "1",
        "14-12-T": "1",
        "16-12-M": "1",
        "16-12-T": "0",
      },
      {
        "tecnico": "Técnico 2",
        "13-12-M": "2",
        "13-12-T": "0",
        "14-12-M": "0",
        "14-12-T": "2",
        "16-12-M": "0",
        "16-12-T": "2",
      },
      {
        "tecnico": "Técnico 3",
        "13-12-M": "1",
        "13-12-T": "2",
        "14-12-M": "1",
        "14-12-T": "0",
        "16-12-M": "1",
        "16-12-T": "1",
      },
      {
        "tecnico": "Técnico 4",
        "13-12-M": "2",
        "13-12-T": "1",
        "14-12-M": "1",
        "14-12-T": "0",
        "16-12-M": "0",
        "16-12-T": "1",
      },
      {
        "tecnico": "Técnico 5",
        "13-12-M": "0",
        "13-12-T": "1",
        "14-12-M": "0",
        "14-12-T": "1",
        "16-12-M": "0",
        "16-12-T": "1",
      },
    ];

    _rows = tecnicos.map((tecnico) {
      return PlutoRow(
        cells: {
          'tecnico': PlutoCell(value: tecnico["tecnico"]),
          '13-12-M': PlutoCell(value: tecnico["13-12-M"]),
          '13-12-T': PlutoCell(value: tecnico["13-12-T"]),
          '14-12-M': PlutoCell(value: tecnico["14-12-M"]),
          '14-12-T': PlutoCell(value: tecnico["14-12-T"]),
          '16-12-M': PlutoCell(value: tecnico["16-12-M"]),
          '16-12-T': PlutoCell(value: tecnico["16-12-T"]),
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text(
              'Disponibilidade dos Técnicos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: PlutoGrid(
                columns: _columns,
                rows: _rows,
                columnGroups: _columnGroups,
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    gridBorderColor: Colors.grey,
                  ),
                ),
                onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                  final tecnico = event.row.cells['tecnico']?.value;
                  print('Duplo clique no técnico: $tecnico');
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique duas vezes em um dos números para puxar as informações do Técnico para o formulário',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
