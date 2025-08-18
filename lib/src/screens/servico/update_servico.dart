import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/layout/report_menu_action.dart';
import 'package:serv_oeste/src/components/screen/cards/card_builder_form.dart';
import 'package:serv_oeste/src/components/screen/client_selection_modal.dart';
import 'package:serv_oeste/src/components/screen/elevated_form_button.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/validators/servico_validator.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/servico/servico_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UpdateServico extends StatefulWidget {
  final int id;
  final int clientId;

  const UpdateServico({
    super.key,
    required this.id,
    required this.clientId
  });

  @override
  State<UpdateServico> createState() => _UpdateServicoState();
}

class _UpdateServicoState extends State<UpdateServico> {
  late final ServicoBloc _servicoBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final ClienteBloc _clienteBloc;

  late TextEditingController _nomeTecnicoController;
  late TextEditingController _nomeClienteController;
  late TextEditingController _enderecoController;

  final ServicoForm _servicoUpdateForm = ServicoForm();
  final ClienteForm _clienteUpdateForm = ClienteForm();
  final ServicoValidator _servicoUpdateValidator = ServicoValidator(isUpdate: true);
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  bool deactivateClientFields = false;

  void _getSelectedClientById(String id) {
    int? convertedId = int.tryParse(id);

    if (convertedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ID inválido. Por favor, insira um número."),
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
    _nomeTecnicoController.text = servico.nomeTecnico?? "";
    _servicoUpdateForm.setForm(servico);
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)')),
    );
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
      submitText: '',
      shouldBuildButton: false,
      onSubmit: () {  },
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: AlertDialog(
            title: const Text(
              "Histórico do serviço",
              textAlign: TextAlign.center,
            ),
            backgroundColor: const Color(0xFFF9F9FF),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(4),
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
                    mainAxisSize: MainAxisSize.min,
                    children: _servicoUpdateForm.historico.value
                        .split('\n')
                        .expand((texto) => [
                      Text(
                        texto,
                        textAlign: TextAlign.left,
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                        height: 10,
                      ),
                    ])
                        .toList()
                      ..removeLast(),
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedFormButton(
                text: "Ok",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
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
    _servicoBloc.add(ServicoSearchOneEvent(id: widget.id));
    _clienteBloc.add(ClienteSearchOneEvent(id: widget.clientId));
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
            }
            else if (state is ServicoSearchOneSuccessState) {
              _populateServicoFormWithState(state.servico);
            }
            else if (state is ServicoErrorState) {
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
              ReportMenuActionButton(
                servicoBloc: _servicoBloc,
                clienteBloc: _clienteBloc
              ),
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
              )
            )
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
