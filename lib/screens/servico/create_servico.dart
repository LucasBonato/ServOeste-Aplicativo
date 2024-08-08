import 'package:flutter/material.dart';
import 'package:serv_oeste/util/constants/constants.dart';
import 'package:serv_oeste/widgets/dropdown_field.dart';
import 'package:serv_oeste/widgets/mask_field.dart';
import 'package:serv_oeste/widgets/search_dropdown_field.dart';

class CreateServico extends StatefulWidget {
  const CreateServico({super.key});

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico> {
  late TextEditingController _equipamentoController, _marcaController, _filialController, _dataAtendimentoPrevistaController, _horarioPrevistoController, _tecnicoController;
  bool equipamentoValidation = false, marcaValidation = false, filialValidation = false, dataAtendimentoPrevistaValidation = false, horarioPrevistoValidation = false, tecnicoValidation = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _equipamentoController = TextEditingController();
    _marcaController = TextEditingController();
    _filialController = TextEditingController();
    _dataAtendimentoPrevistaController = TextEditingController();
    _horarioPrevistoController = TextEditingController();
    _tecnicoController = TextEditingController();
  }

  @override
  void dispose() {
    _equipamentoController.dispose();
    _marcaController.dispose();
    _filialController.dispose();
    _dataAtendimentoPrevistaController.dispose();
    _horarioPrevistoController.dispose();
    _tecnicoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Novo Serviço"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          CustomSearchDropDown(
            label: "Equipamento",
            maxLength: 80,
            hide: true,
            errorMessage: _errorMessage,
            dropdownValues: Constants.equipamentos,
            onChanged: (value) {},
            validation: equipamentoValidation,
            controller: _equipamentoController
          ),
          CustomSearchDropDown(
            label: "Marca",
            maxLength: 40,
            hide: true,
            errorMessage: _errorMessage,
            dropdownValues: Constants.marcas,
            onChanged: (value) {},
            validation: marcaValidation,
            controller: _marcaController
          ),
          CustomDropdownField(
            label: "Filial",
            dropdownValues: Constants.filiais,
            controller: _filialController
          ),
          CustomMaskField(
            label: "Data Atendimento Previsto",
            hint: "",
            mask: "##/##/####",
            type: TextInputType.datetime,
            maxLength: 10,
            hide: true,
            errorMessage: _errorMessage,
            onChanged: (value) {},
            validation: dataAtendimentoPrevistaValidation,
            controller: _dataAtendimentoPrevistaController
          ),
          CustomDropdownField(
            label: "Horário Previsto",
            dropdownValues: Constants.dataAtendimento,
            controller: _horarioPrevistoController
          ),
          CustomSearchDropDown(
            label: "Técnico",
            hide: true,
            errorMessage: _errorMessage,
            maxLength: 40,
            dropdownValues: [],
            onChanged: (value) {},
            validation: tecnicoValidation,
            controller: _tecnicoController
          )
          ],
        ),
      ),
    );
  }
}
