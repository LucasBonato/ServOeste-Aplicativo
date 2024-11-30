import 'package:flutter/material.dart';

class TableTecnicosModal extends StatefulWidget {
  const TableTecnicosModal({super.key});

  @override
  State<TableTecnicosModal> createState() => _TableTecnicosModalState();
}

class _TableTecnicosModalState extends State<TableTecnicosModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Disponibilidade dos Técnicos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey, width: 0.5),
              children: [
                _buildHeaderRow(),
                ..._buildTechnicianRows(),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Clique duas vezes em um dos números para puxar as informações do Técnico para o formulário',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        Container(),
        _buildCell('13/12/24\nSexta'),
        _buildCell('14/12/24\nSábado'),
        _buildCell('16/12/24\nSegunda'),
      ],
    );
  }

  List<TableRow> _buildTechnicianRows() {
    List<List<int>> data = [
      [1, 0, 1, 1, 0, 0],
      [2, 0, 0, 2, 0, 2],
      [1, 2, 1, 1, 0, 1],
      [2, 1, 2, 0, 2, 0],
      [0, 1, 0, 1, 0, 1],
    ];

    return List.generate(data.length, (index) {
      return TableRow(
        children: [
          _buildCell('Técnico ${index + 1}'),
          ...data[index].map((value) {
            return GestureDetector(
              onDoubleTap: () {
                print('Duplo clique em Técnico ${index + 1}, valor: $value');
              },
              child: _buildCell(value.toString(), highlight: value == 2),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildCell(String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight ? Colors.blue[100] : Colors.white,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
