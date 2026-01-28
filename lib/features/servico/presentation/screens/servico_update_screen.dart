import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/shared/widgets/formFields/field_labels.dart';
import 'package:serv_oeste/shared/widgets/layout/report_menu_action.dart';
import 'package:serv_oeste/shared/widgets/screen/cards/card_builder_form.dart';
import 'package:serv_oeste/shared/widgets/screen/client_selection_modal.dart';
import 'package:serv_oeste/shared/widgets/screen/elevated_form_button.dart';
import 'package:serv_oeste/shared/widgets/screen/history_service_table.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico.dart';
import 'package:serv_oeste/features/servico/domain/validators/servico_validator.dart';
import 'package:serv_oeste/shared/widgets/screen/base_form_screen.dart';
import 'package:serv_oeste/features/cliente/presentation/widgets/cliente_form_widget.dart';
import 'package:serv_oeste/features/servico/presentation/widgets/servico_form_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicoUpdateScreen extends StatefulWidget {
  final int id;
  final int clientId;

  const ServicoUpdateScreen({super.key, required this.id, required this.clientId});

  @override
  State<ServicoUpdateScreen> createState() => _ServicoUpdateScreenState();
}

class _ServicoUpdateScreenState extends State<ServicoUpdateScreen> {
  late final ServicoBloc _servicoBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final ClienteBloc _clienteBloc;

  late TextEditingController _nomeTecnicoController;
  late TextEditingController _nomeClienteController;
  late TextEditingController _enderecoController;

  late ServicoValidator _servicoUpdateValidator = ServicoValidator(isUpdate: true);

  final ServicoForm _servicoUpdateForm = ServicoForm();
  final ClienteForm _clienteUpdateForm = ClienteForm();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  bool deactivateClientFields = false;

  void _getSelectedClientById(String id) {
    int? convertedId = int.tryParse(id);

    if (convertedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ID inválido. Por favor, selecione um serviço."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _clienteBloc.add(ClienteSearchOneEvent(id: convertedId));
  }

  void _setClientFieldsValues(Cliente cliente) {
    deactivateClientFields = false;
    _nomeClienteController.text = cliente.nome ?? '';
    _clienteUpdateForm.setNome(cliente.nome ?? '');
    _clienteUpdateForm.setTelefoneFixo(cliente.telefoneFixo ?? '');
    _clienteUpdateForm.setTelefoneCelular(cliente.telefoneCelular ?? '');
    _clienteUpdateForm.setMunicipio(cliente.municipio ?? '');
    _clienteUpdateForm.setBairro(cliente.bairro ?? '');

    List<String> enderecoParts = cliente.endereco?.split(',') ?? [];

    _clienteUpdateForm.setRua(enderecoParts.isNotEmpty ? enderecoParts.first.trim() : '');
    _clienteUpdateForm.setNumero(enderecoParts.length > 1 ? enderecoParts[1].trim() : '');
    _clienteUpdateForm.setComplemento(enderecoParts.length > 2 ? enderecoParts.sublist(2).join(',').trim() : '');

    _servicoUpdateForm.setIdCliente(cliente.id);
    _servicoUpdateForm.setNomeCliente(cliente.nome ?? '');
    deactivateClientFields = true;
  }

  void _populateServicoFormWithState(Servico servico) {
    final originalId = _servicoUpdateForm.id.value;

    _nomeTecnicoController.text = servico.nomeTecnico ?? "";
    _servicoUpdateForm.setForm(servico);

    _servicoUpdateForm.setId(originalId ?? widget.id);
  }

  bool _isValidForm() {
    _clienteFormKey.currentState?.validate();
    _servicoFormKey.currentState?.validate();

    final ValidationResult response = _servicoUpdateValidator.validate(_servicoUpdateForm);
    return response.isValid;
  }

  void _updateServico() {
    if (!_isValidForm()) {
      return;
    }

    Servico servico = Servico.fromForm(_servicoUpdateForm);
    _servicoBloc.add(ServicoUpdateEvent(servico: servico));
  }

  void _handleError(ServicoErrorState state) {
    ErrorEntity error = state.error;

    _servicoUpdateValidator.applyBackendError(error);
    _servicoFormKey.currentState?.validate();
    _servicoUpdateValidator.cleanExternalErrors();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "[ERROR] Informação(ões) inválida(s) ao Atualizar o Serviço.",
        ),
      ),
    );
  }

  void _showClientSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ClientSelectionModal(
            nomeController: _nomeClienteController,
            enderecoController: _enderecoController,
            onClientSelected: _getSelectedClientById,
          ),
        );
      },
    );
  }

  Widget _buildClientForm() {
    return ClienteFormWidget(
      clienteForm: _clienteUpdateForm,
      nomeController: _nomeClienteController,
      isJustShowFields: deactivateClientFields,
      bloc: _clienteBloc,
      shouldBuildButton: false,
      onSubmit: () {},
      submitText: '',
    );
  }

  Widget _buildServiceForm() {
    return ServicoFormWidget(
      bloc: _servicoBloc,
      form: _servicoUpdateForm,
      formKey: _servicoFormKey,
      validator: _servicoUpdateValidator,
      tecnicoBloc: _tecnicoBloc,
      nameTecnicoController: _nomeTecnicoController,
      submitText: "",
      onSubmit: () {},
      successMessage: 'Serviço atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)',
      isUpdate: true,
    );
  }

  Widget _buildMainFormLayout(bool isMobile) {
    final Widget serviceForm = CardBuilderForm(title: "Serviço", child: _buildServiceForm());

    final List<Widget> children = [
      CardBuilderForm(title: "Cliente", child: _buildClientForm()),
      const SizedBox(height: 12),
      ElevatedFormButton(text: "Alterar Cliente", onPressed: () => _showClientSelectionModal(context)),
      if (isMobile) ...[
        const SizedBox(height: 12),
        serviceForm,
      ],
      const SizedBox(height: 8),
      BuildFieldLabels(isClientAndService: false),
    ];

    if (isMobile) {
      return Column(
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: serviceForm,
        ),
      ],
    );
  }

  Future<dynamic> buildDescriptionHistoryDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => ServiceHistoryTable(
        historico: _servicoUpdateForm.historico.value,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _servicoUpdateForm.setId(widget.id);
    _nomeTecnicoController = TextEditingController();
    _nomeClienteController = TextEditingController();
    _enderecoController = TextEditingController();
    _servicoBloc = context.read<ServicoBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();

    _servicoUpdateValidator = ServicoValidator(
      isUpdate: true,
      isFieldEnabled: _isServicoFieldEnabled,
    );

    _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
    _clienteBloc.add(ClienteSearchOneEvent(id: widget.clientId));
  }

  bool _isServicoFieldEnabled(String fieldName) {
    final currentSituation = _servicoUpdateForm.situacao.value;

    final disabledSituations = {
      "dataInicioGarantia": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Não aprovado pelo cliente',
        'Compra',
        'Orçamento aprovado',
        'Aguardando cliente retirar',
        'Não retira há 3 meses'
      ],
      "dataFinalGarantia": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Não aprovado pelo cliente',
        'Compra',
        'Orçamento aprovado',
        'Aguardando cliente retirar',
        'Não retira há 3 meses'
      ],
      "valor": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
      ],
      "valorPecas": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
      ],
      "formaPagamento": [
        'Aguardando agendamento',
        'Aguardando atendimento',
        'Cancelado',
        'Sem defeito',
        'Aguardando orçamento',
        'Aguardando aprovação do cliente',
        'Não aprovado pelo cliente',
        'Compra',
      ],
    };

    final situations = disabledSituations[fieldName];
    if (situations == null) return true;

    return !situations.contains(currentSituation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ServicoBloc, ServicoState>(
          listenWhen: (previous, current) => current is ServicoSearchOneSuccessState || current is ServicoUpdateSuccessState || current is ServicoErrorState,
          listener: (context, state) {
            if (state is ServicoUpdateSuccessState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, true);
                }
              });
            } else if (state is ServicoSearchOneSuccessState) {
              _populateServicoFormWithState(state.servico);
            } else if (state is ServicoErrorState) {
              _handleError(state);
            }
          },
        ),
        BlocListener<ClienteBloc, ClienteState>(
          listener: (context, state) {
            if (state is ClienteSearchOneSuccessState) {
              _setClientFieldsValues(state.cliente);
            }
          },
        ),
      ],
      child: BlocBuilder<ServicoBloc, ServicoState>(
        buildWhen: (previous, current) => current is ServicoSearchOneSuccessState || current is ServicoSearchOneLoadingState,
        builder: (context, state) {
          return BaseFormScreen(
            shouldActivateEvent: true,
            sizeMultiplier: 2,
            title: "Consultar/Atualizar Serviço",
            actions: [
              ReportMenuActionButton(servicoBloc: _servicoBloc, clienteBloc: _clienteBloc),
            ],
            child: Skeletonizer(
              enabled: state is ServicoSearchOneLoadingState,
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isMobile = constraints.maxWidth < 950;
                      return _buildMainFormLayout(isMobile);
                    },
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 750),
                    child: Column(
                      children: [
                        ElevatedFormButton(
                          text: "Ver Histórico de Atendimento",
                          onPressed: () => buildDescriptionHistoryDialog(context),
                        ),
                        const SizedBox(height: 16),
                        ElevatedFormButton(
                          text: "Atualizar Serviço",
                          onPressed: _updateServico,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nomeTecnicoController.dispose();
    _nomeClienteController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }
}
