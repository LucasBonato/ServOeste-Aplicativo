import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_filter.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_form.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente_request.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/servico_request.dart';
import 'package:serv_oeste/shared/widgets/formFields/custom_search_form_field.dart';
import 'package:serv_oeste/shared/widgets/formFields/field_labels.dart';
import 'package:serv_oeste/shared/widgets/screen/cards/card_builder_form.dart';
import 'package:serv_oeste/shared/widgets/screen/filtered_clients_table.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_table_modal.dart';
import 'package:serv_oeste/features/cliente/presentation/bloc/cliente_bloc.dart';
import 'package:serv_oeste/features/servico/presentation/bloc/servico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/cliente/domain/entities/cliente.dart';
import 'package:serv_oeste/shared/models/error/error_entity.dart';
import 'package:serv_oeste/features/cliente/domain/validators/cliente_validator.dart';
import 'package:serv_oeste/features/servico/domain/validators/servico_validator.dart';
import 'package:serv_oeste/shared/widgets/screen/base_form_screen.dart';
import 'package:serv_oeste/features/cliente/presentation/widgets/cliente_form_widget.dart';
import 'package:serv_oeste/features/servico/presentation/widgets/servico_form_widget.dart';
import 'package:serv_oeste/shared/utils/debouncer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicoCreateScreen extends StatefulWidget {
  final bool isClientAndService;

  const ServicoCreateScreen({
    super.key,
    this.isClientAndService = true,
  });

  @override
  State<ServicoCreateScreen> createState() => _ServicoCreateScreenState();
}

class _ServicoCreateScreenState extends State<ServicoCreateScreen> {
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

    _debouncer.execute(
      () => _clienteBloc.add(
        ClienteSearchEvent(
          filter: ClienteFilter(
            nome: _nomeClienteController.text,
            endereco: _enderecoController.text,
          ),
        ),
      ),
    );
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
        return TecnicoTableModal(
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

  void _onAddService() {
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
    } else {
      _servicoBloc.add(
        ServicoRegisterEvent(
          servico: ServicoRequest.fromServicoForm(servico: _servicoForm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicoBloc, ServicoState>(
      listenWhen: (previous, current) =>
          current is ServicoRegisterSuccessState ||
          current is ServicoErrorState,
      listener: (context, state) {
        if (state is ServicoRegisterSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          });
        }

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
                        ? Color(0xFF007BFF)
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
                Color(0xFF007BFF),
                _onAddService,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFormLayout(bool isMobile) {
    final Widget clienteSection = Column(
      children: [
        CardBuilderForm(
            title: "Pesquise um Cliente", child: _buildClientForm()),
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
