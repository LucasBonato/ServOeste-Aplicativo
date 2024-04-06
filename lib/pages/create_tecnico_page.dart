import 'package:flutter/material.dart';

class CreateTecnico extends StatefulWidget {
  final VoidCallback onIconPressed;

  const CreateTecnico({super.key, required this.onIconPressed});

  @override
  State<CreateTecnico> createState() => _CreateTecnicoState();
}

class _CreateTecnicoState extends State<CreateTecnico> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
             icon: const Icon(Icons.arrow_back),
              onPressed: widget.onIconPressed,
          ),
        title: const Text("Novo Técnico"),
        centerTitle: true,
        ),
      body: Column(),
    );
  }
}
