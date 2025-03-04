import 'package:flutter/material.dart';

class FilteredClientsTable extends StatelessWidget {
  final List<Map<String, String>> clientesFiltrados;
  final Function(String) onClientSelected;

  const FilteredClientsTable({
    super.key,
    required this.clientesFiltrados,
    required this.onClientSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: true, scrollbars: true),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: 225,
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Endereço')),
                ],
                rows: clientesFiltrados.isEmpty
                    ? [
                        DataRow(cells: [
                          DataCell(Text('')),
                          DataCell(Text('Nenhum cliente encontrado')),
                          DataCell(Text('')),
                        ]),
                      ]
                    : clientesFiltrados.map((cliente) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(cliente['id']!),
                              onDoubleTap: () => onClientSelected(cliente['id']!),
                            ),
                            DataCell(
                              Text(cliente['nome']!),
                              onDoubleTap: () => onClientSelected(cliente['id']!),
                            ),
                            DataCell(
                              Text(cliente['endereco']!),
                              onDoubleTap: () => onClientSelected(cliente['id']!),
                            ),
                          ],
                        );
                      }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
