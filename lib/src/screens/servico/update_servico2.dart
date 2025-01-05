import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:serv_oeste/src/util/formatters.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class UpdateServico extends StatefulWidget {
  final int id;

  const UpdateServico({super.key, required this.id});

  @override
  State<UpdateServico> createState() => _UpdateServicoState();
}

class _UpdateServicoState extends State<UpdateServico> {
  late final ServicoBloc _servicoBloc;
  final ServicoForm _servicoUpdateForm = ServicoForm();
  final ServicoValidator _servicoUpdateValidator = ServicoValidator();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  List<String> _dropdownValuesNomes = [];

  @override
  void initState() {
    super.initState();
    _servicoUpdateForm.setId(widget.id);
    _servicoBloc = context.read<ServicoBloc>();
    _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
  }

  void _updateServico() {
    if (_isValidForm() == false) {
      return;
    }

    // List<String> nomes = _servicoUpdateForm.nome.value.split(" ");
    // _servicoUpdateForm.nome.value = nomes.first;
    // String sobrenome = nomes.sublist(1).join(" ").trim();

    // _servicoBloc.add(ServicoUpdateEvent(
    //     servico: Servico.fromForm(_servicoUpdateForm), sobrenome: sobrenome));
    // _servicoUpdateForm.nome.value = "${nomes.first} $sobrenome";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço atualizado com sucesso!')),
    );
  }

  bool _isValidForm() {
    _servicoFormKey.currentState?.validate();
    final ValidationResult response =
        _servicoUpdateValidator.validate(_servicoUpdateForm);
    return response.isValid;
  }

  void _handleBackNavigation() {
    _servicoBloc.add(ServicoSearchEvent());
    Navigator.pop(context, "Back");
  }

  Widget _buildCard(Widget child, String title) {
    return Align(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEAE6E5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _handleBackNavigation,
              )
            ],
          ),
        ),
        title: const Text(
          "Voltar",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Color(0xFCFDFDFF),
        elevation: 0,
      ),
      body: BlocBuilder<ServicoBloc, ServicoState>(
        bloc: _servicoBloc,
        buildWhen: (previousState, state) {
          if (state is ServicoSearchSuccessState) {
            _servicoUpdateForm.nomeCliente.value = Constants.filiais[0];
            _servicoUpdateForm.nomeTecnico.value = Constants.filiais[0];
            _servicoUpdateForm.equipamento.value = Constants.equipamentos[0];
            _servicoUpdateForm.filial.value = Constants.filiais[0];
            _servicoUpdateForm.horario.value = Constants.dataAtendimento[0];
            _servicoUpdateForm.marca.value = Constants.marcas[0];
            _servicoUpdateForm.garantia.value = Constants.garantias[0];
            _servicoUpdateForm.situacao.value =
                Constants.situationServiceList[0];
            _servicoUpdateForm.descricao.value = "Descrição Atualizada";
            _servicoUpdateForm.dataAtendimentoPrevisto.value = "2025-01-01";
            _servicoUpdateForm.dataAtendimentoEfetivo.value = "2025-01-02";
            _servicoUpdateForm.dataAtendimentoAbertura.value = "2025-01-03";

            return true;
          }
          return false;
        },
        builder: (context, state) {
          print(state);
          return (state is ServicoSearchSuccessState)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _servicoFormKey,
                          child: Column(
                            children: [
                              CustomSearchDropDown(
                                label: 'Nome Cliente*',
                                dropdownValues: Constants.filiais,
                                valueNotifier: _servicoUpdateForm.nomeCliente,
                                onChanged: _servicoUpdateForm.setNomeCliente,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'nomeCliente',
                                ),
                                enabled: false,
                              ),
                              SizedBox(height: 32),
                              CustomSearchDropDown(
                                label: 'Nome Técnico*',
                                dropdownValues: Constants.filiais,
                                valueNotifier: _servicoUpdateForm.nomeTecnico,
                                onChanged: _servicoUpdateForm.setNomeTecnico,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'nomeTecnico',
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomSearchDropDown(
                                label: 'Equipamento*',
                                dropdownValues: Constants.equipamentos,
                                valueNotifier: _servicoUpdateForm.equipamento,
                                onChanged: _servicoUpdateForm.setEquipamento,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'equipamento',
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomDropdownField(
                                label: 'Filial*',
                                dropdownValues: Constants.filiais,
                                valueNotifier: _servicoUpdateForm.filial,
                                onChanged: _servicoUpdateForm.setFilial,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'filial',
                                ),
                              ),
                              CustomDropdownField(
                                label: 'Horário*',
                                dropdownValues: Constants.dataAtendimento,
                                valueNotifier: _servicoUpdateForm.horario,
                                onChanged: _servicoUpdateForm.setHorario,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'horarioPrevisto',
                                ),
                              ),
                              CustomSearchDropDown(
                                label: 'Marca*',
                                dropdownValues: Constants.marcas,
                                valueNotifier: _servicoUpdateForm.marca,
                                onChanged: _servicoUpdateForm.setMarca,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'marca',
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomDropdownField(
                                label: 'Garantia',
                                dropdownValues: Constants.garantias,
                                valueNotifier: _servicoUpdateForm.garantia,
                                onChanged: _servicoUpdateForm.setGarantia,
                              ),
                              CustomDropdownField(
                                label: 'Situação*',
                                dropdownValues: Constants.situationServiceList,
                                valueNotifier: _servicoUpdateForm.situacao,
                                onChanged: _servicoUpdateForm.setSituacao,
                                validator: _servicoUpdateValidator.byField(
                                  _servicoUpdateForm,
                                  'situacao',
                                ),
                              ),
                              CustomDatePicker(
                                hint: 'Selecione a data prevista',
                                label: 'Data Atendimento Previsto*',
                                mask: [],
                                maxLength: 10,
                                hide: true,
                                type: TextInputType.datetime,
                                valueNotifier:
                                    _servicoUpdateForm.dataAtendimentoPrevisto,
                                onChanged: _servicoUpdateForm
                                    .setDataAtendimentoPrevisto,
                                validator: _servicoUpdateValidator.byField(
                                    _servicoUpdateForm,
                                    'dataAtendimentoPrevisto'),
                              ),
                              CustomDatePicker(
                                hint: 'Selecione a data efetiva',
                                label: 'Data Atendimento Efetivo',
                                mask: [],
                                maxLength: 10,
                                hide: true,
                                type: TextInputType.datetime,
                                valueNotifier:
                                    _servicoUpdateForm.dataAtendimentoEfetivo,
                                onChanged: _servicoUpdateForm
                                    .setDataAtendimentoEfetivo,
                                validator: _servicoUpdateValidator.byField(
                                    _servicoUpdateForm,
                                    'dataAtendimentoEfetivo'),
                              ),
                              CustomDatePicker(
                                hint: 'Selecione a data de abertura',
                                label: 'Data Atendimento Abertura',
                                mask: [],
                                maxLength: 10,
                                hide: true,
                                type: TextInputType.datetime,
                                valueNotifier:
                                    _servicoUpdateForm.dataAtendimentoAbertura,
                                onChanged: _servicoUpdateForm
                                    .setDataAtendimentoAbertura,
                                validator: _servicoUpdateValidator.byField(
                                    _servicoUpdateForm,
                                    'dataAtendimentoAbertura'),
                              ),
                              CustomTextFormField(
                                hint: "Descrição...",
                                label: "Descrição*",
                                type: TextInputType.multiline,
                                maxLength: 255,
                                maxLines: 3,
                                minLines: 1,
                                hide: false,
                                valueNotifier: _servicoUpdateForm.descricao,
                                validator: _servicoUpdateValidator.byField(
                                    _servicoUpdateForm,
                                    ErrorCodeKey.descricao.name),
                                onChanged: _servicoUpdateForm.setDescricao,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
