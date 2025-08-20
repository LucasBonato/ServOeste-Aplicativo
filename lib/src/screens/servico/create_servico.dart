import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/screen/cards/card_builder_form.dart';
import 'package:serv_oeste/src/components/screen/filtered_clients_table.dart';
import 'package:serv_oeste/src/components/screen/table_technical.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/validators/cliente_validator.dart';
import 'package:serv_oeste/src/models/validators/servico_validator.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/servico/servico_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CreateServico extends StatefulWidget {
  final bool isClientAndService;

  const CreateServico({
    super.key,
    this.isClientAndService = true,
  });

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico> {
  bool _isDataLoaded = true;
  final Debouncer _debouncer = Debouncer();
  late bool isClientAndService;
  late List<Cliente> _clientes;

  late TextEditingController _nomeTecnicoController;
  late TextEditingController _nomeClienteController;
  late TextEditingController _enderecoController;

  late final ServicoBloc _servicoBloc;
  late final ClienteBloc _clienteBloc;
  late final TecnicoBloc _tecnicoBloc;

  final ClienteForm _clienteForm = ClienteForm();
  final ClienteValidator _clienteValidator = ClienteValidator();

  final ServicoForm _servicoForm = ServicoForm();
  final ServicoValidator _servicoValidator = ServicoValidator();

  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isClientAndService = widget.isClientAndService;
    _clientes = [];
    _nomeTecnicoController = TextEditingController();
    _nomeClienteController = TextEditingController();
    _enderecoController = TextEditingController();
    _servicoBloc = context.read<ServicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
  }

  void _getClienteById(String id) {
    final clienteSelecionado = _clientes.firstWhere(
      (cliente) => cliente.id.toString() == id,
      orElse: () => Cliente(),
    );

    if (clienteSelecionado.id != null) {
      _nomeClienteController.text = clienteSelecionado.nome ?? '';
      _enderecoController.text = clienteSelecionado.endereco ?? '';
      _servicoForm.setIdCliente(clienteSelecionado.id);

      setState(() {
        isClientAndService = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente não encontrado.'),
        ),
      );
    }
  }

  void _onSearchFieldChanged() {
    _isDataLoaded = false;

    _debouncer.execute(() => _clienteBloc.add(
          ClienteSearchEvent(
            nome: _nomeClienteController.text,
            endereco: _enderecoController.text,
          ),
        ));
  }

  void _onShowAvailabilityTechnicianTable() {
    final String equipamentoSelected = _servicoForm.equipamento.value;
    int idEspecialidade = 12;
    if (Constants.equipamentos.contains(equipamentoSelected)) {
      idEspecialidade = Constants.equipamentos.indexOf(equipamentoSelected) + 1;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TableTecnicosModal(
          especialidadeId: idEspecialidade,
          setValuesAvailabilityTechnicianTable: _setTableValues,
        );
      },
    );
  }

  void _setTableValues(
      String nomeTecnico, String data, String periodo, int idTecnico) {
    _nomeTecnicoController.text = nomeTecnico;
    _servicoForm.setNomeTecnico(nomeTecnico);
    _servicoForm.setDataAtendimentoPrevisto(data);
    _servicoForm.setHorario(periodo);
    _servicoForm.setIdTecnico(idTecnico);
  }

  bool _isServiceFormValid() {
    _servicoFormKey.currentState?.validate();
    final ValidationResult response = _servicoValidator.validate(_servicoForm);
    return response.isValid;
  }

  bool _isClientFormValid() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response = _clienteValidator.validate(_clienteForm);
    return response.isValid;
  }

  void _onAddService() {
    bool isClientNotValid = !_isClientFormValid();
    bool isServiceNotValid = !_isServiceFormValid();

    if ((isClientNotValid || !isClientAndService) && isServiceNotValid) {
      return;
    }

    if (isClientAndService) {
      List<String> nomes = _clienteForm.nome.value.split(" ");
      _clienteForm.setNome(nomes.first);

      String sobrenomeCliente = nomes.sublist(1).join(" ").trim();

      _servicoBloc.add(
        ServicoRegisterPlusClientEvent(
          servico: ServicoRequest.fromServicoForm(servico: _servicoForm),
          cliente: ClienteRequest.fromClienteForm(
              cliente: _clienteForm, sobrenome: sobrenomeCliente),
        ),
      );

      _clienteForm.setNome("${nomes.first} $sobrenomeCliente");
      return;
    }

    _servicoBloc.add(
      ServicoRegisterEvent(
        servico: ServicoRequest.fromServicoForm(servico: _servicoForm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicoBloc, ServicoState>(
      listenWhen: (previous, current) =>
          current is ServicoRegisterSuccessState ||
          current is ServicoErrorState,
      listener: (context, state) {
        if (state is TecnicoRegisterSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is ServicoErrorState) {
          ErrorEntity error = state.error;
          _servicoValidator.applyBackendError(error);
          _servicoFormKey.currentState?.validate();

          if (isClientAndService) {
            _clienteValidator.applyBackendError(error);
            _clienteFormKey.currentState?.validate();
            _clienteValidator.cleanExternalErrors();
          }
          _servicoValidator.cleanExternalErrors();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "[ERRO] Informação(ões) inválida(s) ao registrar o Serviço: ${error.errorMessage}",
              ),
            ),
          );
        }
      },
      child: BaseFormScreen(
        title: isClientAndService
            ? "Adicionar Cliente/Serviço"
            : "Adicionar Serviço",
        shouldActivateEvent: false,
        sizeMultiplier: 2,
        child: Skeletonizer(
            enabled: false,
            child: Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 950;
                  return _buildMainFormLayout(isMobile);
                }),
                const SizedBox(height: 48),
                ValueListenableBuilder<String>(
                  valueListenable: _servicoForm.equipamento,
                  builder: (context, equipamentoSelecionado, child) {
                    return _buildButton(
                      'Verificar disponibilidade',
                      equipamentoSelecionado.isNotEmpty
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.5),
                      equipamentoSelecionado.isNotEmpty
                          ? _onShowAvailabilityTechnicianTable
                          : () {},
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildButton(
                  isClientAndService
                      ? 'Adicionar Cliente/Serviço'
                      : 'Adicionar Serviço',
                  Colors.blue,
                  _onAddService,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildMainFormLayout(bool isMobile) {
    final Widget clienteSection = Column(
      children: [
        CardBuilderForm(title: "Client", child: _buildClientForm()),
        if (!isClientAndService)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CardBuilderForm(
                title: "Selecione um Cliente",
                child: _buildFilteredClientsTable()),
          ),
        const SizedBox(height: 8),
        BuildFieldLabels(isClientAndService: isClientAndService),
      ],
    );
    final Widget servicoSection =
        CardBuilderForm(title: "Serviço", child: _buildServiceForm());

    if (isMobile) {
      return Column(
        children: [
          clienteSection,
          const SizedBox(height: 16),
          servicoSection,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: clienteSection),
        const SizedBox(width: 16),
        Expanded(child: servicoSection),
      ],
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(600, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilteredClientsTable() {
    return BlocBuilder<ClienteBloc, ClienteState>(
      builder: (context, state) {
        late List<Map<String, String>> filteredClients = [];
        if (state is ClienteSearchSuccessState && !_isDataLoaded) {
          _clientes = state.clientes;
          filteredClients = state.clientes
              .map((cliente) => {
                    'id': cliente.id.toString(),
                    'nome': cliente.nome ?? '',
                    'endereco':
                        '${cliente.municipio ?? ''} - ${cliente.bairro ?? ''} - ${cliente.endereco ?? ''}',
                  })
              .toList();
          _isDataLoaded = true;
        }

        return FilteredClientsTable(
          clientesFiltrados: filteredClients,
          onClientSelected: _getClienteById,
        );
      },
    );
  }

  Widget buildSearchField(
          {required String hint,
          TextEditingController? controller,
          TextInputType? keyboardType}) =>
      CustomSearchTextFormField(
        hint: hint,
        leftPadding: 4,
        rightPadding: 4,
        controller: controller,
        keyboardType: keyboardType,
        onChangedAction: (value) => _onSearchFieldChanged(),
      );

  Widget _buildClientForm() {
    if (isClientAndService) {
      return ClienteFormWidget(
        bloc: _clienteBloc,
        clienteForm: _clienteForm,
        validator: _clienteValidator,
        formKey: _clienteFormKey,
        isClientAndService: isClientAndService,
        isCreateCliente: true,
        shouldBuildButton: false,
        onSubmit: () {},
        submitText: "",
      );
    }
    return Column(
      children: [
        buildSearchField(
          hint: "Nome do Cliente",
          controller: _nomeClienteController,
        ),
        const SizedBox(height: 12),
        buildSearchField(
          hint: "Endereço",
          controller: _enderecoController,
        ),
      ],
    );
  }

  Widget _buildServiceForm() {
    return ServicoFormWidget(
      bloc: _servicoBloc,
      form: _servicoForm,
      formKey: _servicoFormKey,
      validator: _servicoValidator,
      tecnicoBloc: _tecnicoBloc,
      nameTecnicoController: _nomeTecnicoController,
      isClientAndService: isClientAndService,
      onSubmit: () {},
      submitText: "",
      successMessage:
          'Serviço registrado com sucesso! (Caso ele não esteja aparecendo, recarregue a página)',
    );
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }
}
