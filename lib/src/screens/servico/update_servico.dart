// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:serv_oeste/src/components/date_picker.dart';
// import 'package:serv_oeste/src/components/dropdown_field.dart';
// import 'package:serv_oeste/src/components/search_dropdown_field.dart';
// import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
// import 'package:serv_oeste/src/logic/servico/servico_event.dart';
// import 'package:serv_oeste/src/logic/servico/servico_state.dart';
// import 'package:serv_oeste/src/models/enums/error_code_key.dart';
// import 'package:serv_oeste/src/models/servico/servico_form.dart';
// import 'package:serv_oeste/src/models/validators/validator.dart';
// import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
// import 'package:serv_oeste/src/shared/constants.dart';
// import 'package:serv_oeste/src/util/formatters.dart';

// import '../../models/servico/servico.dart';

// class UpdateServico extends StatefulWidget {
//   final int id;

//   const UpdateServico({super.key, required this.id});

//   @override
//   State<UpdateServico> createState() => _UpdateServicoState();
// }

// class _UpdateServicoState extends State<UpdateServico> {
//   late final ServicoBloc _servicoBloc;
//   final ServicoForm _servicoUpdateForm = ServicoForm();
//   final ServicoValidator _servicoUpdateValidator = ServicoValidator();
//   final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _servicoUpdateForm.setId(widget.id);
//     _servicoBloc = context.read<ServicoBloc>();
//     _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
//   }

//   void _updateServico() {
//     if (!_isValidForm()) return;

//     _servicoBloc
//         .add(ServicoUpdateEvent(servico: Servico.fromForm(_servicoUpdateForm)));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Serviço atualizado com sucesso!')),
//     );
//   }

//   bool _isValidForm() {
//     _servicoFormKey.currentState?.validate();
//     return _servicoUpdateValidator.validate(_servicoUpdateForm).isValid;
//   }

//   void _handleBackNavigation() {
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Atualizar Serviço'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: _handleBackNavigation,
//         ),
//       ),
//       body: BlocListener<ServicoBloc, ServicoState>(
//         listener: (context, state) {
//           if (state is ServicoErrorState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage)),
//             );
//           }
//         },
//         child: BlocBuilder<ServicoBloc, ServicoState>(
//           bloc: _servicoBloc,
//           builder: (context, state) {
//             if (state is ServicoSearchOneSuccessState) {
//               _initializeFormFields(state);
//               return SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _servicoFormKey,
//                     child: Column(
//                       children: [
//                         CustomSearchDropDown(
//                           label: 'Nome Cliente*',
//                           dropdownValues: Constants.filiais,
//                           valueNotifier: _servicoUpdateForm.nomeCliente,
//                           onChanged: _servicoUpdateForm.setNomeCliente,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'nomeCliente',
//                           ),
//                         ),
//                         CustomSearchDropDown(
//                           label: 'Nome Técnico*',
//                           dropdownValues: Constants.filiais,
//                           valueNotifier: _servicoUpdateForm.nomeTecnico,
//                           onChanged: _servicoUpdateForm.setNomeTecnico,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'nomeTecnico',
//                           ),
//                         ),
//                         CustomSearchDropDown(
//                           label: 'Equipamento*',
//                           dropdownValues: Constants.equipamentos,
//                           valueNotifier: _servicoUpdateForm.equipamento,
//                           onChanged: _servicoUpdateForm.setEquipamento,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'equipamento',
//                           ),
//                         ),
//                         CustomDropdownField(
//                           label: 'Filial*',
//                           dropdownValues: Constants.filiais,
//                           valueNotifier: _servicoUpdateForm.filial,
//                           onChanged: _servicoUpdateForm.setFilial,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'filial',
//                           ),
//                         ),
//                         CustomDropdownField(
//                           label: 'Horário*',
//                           dropdownValues: Constants.horarioAtendimento,
//                           valueNotifier: _servicoUpdateForm.horario,
//                           onChanged: _servicoUpdateForm.setHorario,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'horarioPrevisto',
//                           ),
//                         ),
//                         CustomSearchDropDown(
//                           label: 'Marca*',
//                           dropdownValues: Constants.marcas,
//                           valueNotifier: _servicoUpdateForm.marca,
//                           onChanged: _servicoUpdateForm.setMarca,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'marca',
//                           ),
//                         ),
//                         CustomDropdownField(
//                           label: 'Garantia',
//                           dropdownValues: Constants.garantias,
//                           valueNotifier: _servicoUpdateForm.garantia,
//                           onChanged: _servicoUpdateForm.setGarantia,
//                         ),
//                         CustomDropdownField(
//                           label: 'Situação*',
//                           dropdownValues: Constants.situationServiceList,
//                           valueNotifier: _servicoUpdateForm.situacao,
//                           onChanged: _servicoUpdateForm.setSituacao,
//                           validator: _servicoUpdateValidator.byField(
//                             _servicoUpdateForm,
//                             'situacao',
//                           ),
//                         ),
//                         CustomTextFormField(
//                           hint: "Descrição...",
//                           label: "Descrição*",
//                           type: TextInputType.multiline,
//                           maxLength: 255,
//                           maxLines: 3,
//                           minLines: 1,
//                           hide: false,
//                           valueNotifier: _servicoUpdateForm.descricao,
//                           validator: _servicoUpdateValidator.byField(
//                               _servicoUpdateForm, ErrorCodeKey.descricao.name),
//                           onChanged: _servicoUpdateForm.setDescricao,
//                         ),
//                         CustomDatePicker(
//                           hint: 'Selecione a data prevista',
//                           label: 'Data Atendimento Previsto*',
//                           mask: [],
//                           maxLength: 10,
//                           type: TextInputType.datetime,
//                           valueNotifier:
//                               _servicoUpdateForm.dataAtendimentoPrevisto,
//                           onChanged:
//                               _servicoUpdateForm.setDataAtendimentoPrevisto,
//                           validator: _servicoUpdateValidator.byField(
//                               _servicoUpdateForm, 'dataAtendimentoPrevisto'),
//                         ),
//                         CustomDatePicker(
//                           hint: 'Selecione a data efetiva',
//                           label: 'Data Atendimento Efetivo',
//                           mask: [],
//                           maxLength: 10,
//                           type: TextInputType.datetime,
//                           valueNotifier:
//                               _servicoUpdateForm.dataAtendimentoEfetivo,
//                           onChanged:
//                               _servicoUpdateForm.setDataAtendimentoEfetivo,
//                           validator: _servicoUpdateValidator.byField(
//                               _servicoUpdateForm, 'dataAtendimentoEfetivo'),
//                         ),
//                         CustomDatePicker(
//                           hint: 'Selecione a data de abertura',
//                           label: 'Data Atendimento Abertura',
//                           mask: [],
//                           maxLength: 10,
//                           type: TextInputType.datetime,
//                           valueNotifier:
//                               _servicoUpdateForm.dataAtendimentoAbertura,
//                           onChanged:
//                               _servicoUpdateForm.setDataAtendimentoAbertura,
//                           validator: _servicoUpdateValidator.byField(
//                               _servicoUpdateForm, 'dataAtendimentoAbertura'),
//                         ),
//                         ElevatedButton(
//                           onPressed: _updateServico,
//                           child: const Text('Atualizar Serviço'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//             return const Center(child: CircularProgressIndicator());
//           },
//         ),
//       ),
//     );
//   }

//   void _initializeFormFields(ServicoSearchOneSuccessState state) {
//     _servicoUpdateForm.nomeCliente.value = state.servico.nomeCliente;
//     _servicoUpdateForm.nomeTecnico.value = state.servico.nomeTecnico;
//     _servicoUpdateForm.equipamento.value = state.servico.equipamento;
//     _servicoUpdateForm.filial.value = state.servico.filial;
//     _servicoUpdateForm.horario.value = state.servico.horarioPrevisto;
//     _servicoUpdateForm.marca.value = state.servico.marca;
//     _servicoUpdateForm.garantia.value = state.servico.garantia!;
//     _servicoUpdateForm.situacao.value = state.servico.situacao;

//     _servicoUpdateForm.dataAtendimentoPrevisto.value =
//         state.servico.dataAtendimentoPrevisto != null
//             ? Formatters.applyDateMask(state.servico.dataAtendimentoPrevisto)
//             : '';
//     _servicoUpdateForm.dataAtendimentoEfetivo.value =
//         state.servico.dataAtendimentoEfetivo != null
//             ? Formatters.applyDateMask(state.servico.dataAtendimentoEfetivo!)
//             : '';
//     _servicoUpdateForm.dataAtendimentoAbertura.value =
//         state.servico.dataAtendimentoAbertura != null
//             ? Formatters.applyDateMask(state.servico.dataAtendimentoAbertura!)
//             : '';
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
