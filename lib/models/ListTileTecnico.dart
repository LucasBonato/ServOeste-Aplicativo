import 'package:flutter/material.dart';

class ListTileTecnico extends StatelessWidget {
  final int id;
  final String nome;
  final String sobrenome;
  final String situacao;
  ListTileTecnico({super.key, required this.id, required this.nome, required this.sobrenome, required this.situacao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text("$id"),
            Text("$nome $sobrenome"),
            Text(situacao),
          ],
        ),
      ),
    );
  }
}
