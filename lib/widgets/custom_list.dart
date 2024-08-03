import 'package:flutter/material.dart';
import 'package:serv_oeste/models/tecnico.dart';

import 'package:super_sliver_list/super_sliver_list.dart';

class CustomListSliver extends StatefulWidget {
  final List<Object>? entidades;

  const CustomListSliver({super.key, required this.entidades});

  @override
  State<CustomListSliver> createState() => _CustomListSliverState();
}

class _CustomListSliverState extends State<CustomListSliver> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: SuperListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        scrollDirection: Axis.vertical,
        itemCount: widget.entidades!.length,
        itemBuilder: (context, index) {
          final Object entidade = widget.entidades![index];
          final int id = entidade.id!;
          final String nomeCompleto = "${tecnico.nome} ${tecnico.sobrenome}";
          final String telefone = transformTelefone(tecnico);
          final String situacao = tecnico.situacao.toString();
          final bool editable = (isSelected && _selectedItens.length == 1 && _selectedItens.contains(id));
          return ListTile(
            tileColor: (_selectedItens.contains(id)) ? Colors.blue.withOpacity(.5) : null,
            leading: Text("${widget.id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            title: Text(${widget.nomeCompleto}, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Telefone: ${widget.telefone}"),
            trailing: (editable) ? IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.edit, color: Colors.white),
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue)),
            ) : Text(widget.situacao),
            onLongPress: () => selectItens(id),
            onTap: () {
              if (_selectedItens.isNotEmpty) {
                selectItens(id);
              }
              if (_selectedItens.isEmpty) {
                isSelected = false;
              }
            }
          );
        },
      )
    );
  }
}
