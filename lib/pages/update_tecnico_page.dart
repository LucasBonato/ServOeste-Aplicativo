import 'package:flutter/material.dart';

class UpdateTecnico extends StatefulWidget {
  final VoidCallback onIconPressed;
  final int id;

  const UpdateTecnico({super.key, required this.onIconPressed, required this.id});

  @override
  State<UpdateTecnico> createState() => _UpdateTecnicoState();
}

class _UpdateTecnicoState extends State<UpdateTecnico> {
  @override
  Widget build(BuildContext context) {
    return Text("${widget.id}");
  }
}
