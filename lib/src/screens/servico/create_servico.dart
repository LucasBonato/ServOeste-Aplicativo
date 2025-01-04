import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/dropdown_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/screens/servico/table_tecnico.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class CreateServico extends StatefulWidget {
  final bool isClientAndService;

  const CreateServico({super.key, this.isClientAndService = true});

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico> {
  Timer? _debounce;
  late List<Tecnico> _tecnicos;
  late List<Cliente> _clientes;
  late List<String> _dropdownNomeClientes;
  late List<String> _dropdownNomeTecnicos;

  late TextEditingController _municipioController;
  late TextEditingController _nomeTecnicoController;

  late final ServicoBloc _servicoBloc;
  late final ClienteBloc _clienteBloc;
  late final TecnicoBloc _tecnicoBloc;
  late final EnderecoBloc _enderecoBloc;

  final ClienteForm _clienteForm = ClienteForm();
  final ClienteValidator _clienteValidator = ClienteValidator();

  final ServicoForm _servicoForm = ServicoForm();
  final ServicoValidator _servicoValidator = ServicoValidator();

  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _tecnicos = [];
    _clientes = [];
    _dropdownNomeTecnicos = [];
    _dropdownNomeClientes = [];
    _municipioController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
    _servicoBloc = context.read<ServicoBloc>();
    _clienteBloc = context.read<ClienteBloc>();
    _tecnicoBloc = context.read<TecnicoBloc>();
    _enderecoBloc = EnderecoBloc();
    super.initState();
  }

  void _onNomeClienteChanged(String nome) {
    _servicoForm.setIdCliente(null);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchClienteNames(nome));
  }

  void _fetchClienteNames(String nome) {
    _clienteForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownNomeClientes.isEmpty) return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
  }

  void _getClienteId(String nome) {
    for (Cliente cliente in _clientes) {
      if (cliente.nome! == _clienteForm.nome.value) {
        _servicoForm.setIdCliente(cliente.id);
      }
    }
  }

  void _onNomeTecnicoChanged(String nome) {
    _servicoForm.setIdTecnico(null);
    if (_servicoForm.equipamento.value.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(Duration(milliseconds: 150), () => _fetchTecnicoNames(nome));
  }

  void _fetchTecnicoNames(String nome) {
    _servicoForm.setNomeTecnico(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownNomeTecnicos.isEmpty) return;
    _tecnicoBloc.add(TecnicoSearchEvent(
        nome: nome, equipamento: _servicoForm.equipamento.value));
  }

  void _getTecnicoId(String nome) {
    _servicoForm.setNomeTecnico(nome);
    for (Tecnico tecnico in _tecnicos) {
      if ("${tecnico.nome!} ${tecnico.sobrenome!}" ==
          _servicoForm.nomeTecnico.value) {
        _servicoForm.setIdTecnico(tecnico.id);
      }
    }
  }

  void _fetchInformationAboutCep(String? cep) {
    if (cep?.length != 9) return;
    _clienteForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  bool _isInputEnabled() {
    return (widget.isClientAndService || _servicoForm.idCliente.value != null);
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
    _servicoForm.setNomeTecnico(nomeTecnico);
    _nomeTecnicoController.text = nomeTecnico;
    _servicoForm.setDataPrevista(data);
    _servicoForm.setHorario(periodo);
    _servicoForm.setIdTecnico(idTecnico);
  }

  bool _isValidServicoForm() {
    _servicoFormKey.currentState?.validate();
    final ValidationResult response = _servicoValidator.validate(_servicoForm);
    return response.isValid;
  }

  bool _isValidClienteForm() {
    _clienteFormKey.currentState?.validate();
    final ValidationResult response = _clienteValidator.validate(_clienteForm);
    return response.isValid;
  }

  void _onAddService() {
    if (_isValidClienteForm() == false && widget.isClientAndService) {
      return;
    }
    if (_isValidServicoForm() == false) {
      return;
    }

    if (widget.isClientAndService) {
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

    if (widget.isClientAndService) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente e Serviço adicionados com sucesso!'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Serviço adicionado com sucesso!'),
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
                onPressed: () => Navigator.pop(context, "Back"),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 950;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 42),
                    Text(
                      widget.isClientAndService
                          ? 'Adicionar Cliente/Serviço'
                          : 'Adicionar Serviço',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    isMobile
                        ? Column(
                            children: [
                              _buildCard(_buildClientForm(), 'Cliente'),
                              const SizedBox(height: 16),
                              _buildCard(_buildServiceForm(), 'Serviço'),
                              const SizedBox(height: 8),
                              widget.isClientAndService
                                  ? BuildFieldLabels()
                                  : BuildFieldLabels(isClientAndService: false),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildCard(_buildClientForm(), 'Cliente'),
                                    const SizedBox(height: 8),
                                    widget.isClientAndService
                                        ? BuildFieldLabels()
                                        : BuildFieldLabels(
                                            isClientAndService: false),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child:
                                    _buildCard(_buildServiceForm(), 'Serviço'),
                              ),
                            ],
                          ),
                    const SizedBox(height: 48),
                    ValueListenableBuilder<String>(
                      valueListenable: _servicoForm.equipamento,
                      builder: (context, equipamentoSelecionado, child) {
                        return _buildButton(
                          'Verificar disponibilidade',
                          equipamentoSelecionado.isNotEmpty
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.5),
                          equipamentoSelecionado.isNotEmpty
                              ? _onShowAvailabilityTechnicianTable
                              : () {},
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocListener<ServicoBloc, ServicoState>(
                      bloc: _servicoBloc,
                      listener: (context, state) {
                        if (state is ServicoRegisterSuccessState) {
                          Navigator.pop(context);
                        } else if (state is ServicoErrorState) {
                          ErrorEntity error = state.error;
                          if (widget.isClientAndService) {
                            _clienteValidator.applyBackendError(error);
                            _clienteFormKey.currentState?.validate();
                            _clienteValidator.cleanExternalErrors();
                          }
                          _servicoValidator.applyBackendError(error);
                          _servicoFormKey.currentState?.validate();
                          _servicoValidator.cleanExternalErrors();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "[ERROR] Informação(ões) inválida(s) ao registrar o Serviço: ${error.errorMessage}"),
                            ),
                          );
                        }
                      },
                      child: _buildButton(
                          widget.isClientAndService
                              ? 'Adicionar Cliente/Serviço'
                              : 'Adicionar Serviço',
                          Colors.blue,
                          _onAddService),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildClientForm() {
    return Form(
      key: _clienteFormKey,
      child: Column(
        children: [
          BlocListener<ClienteBloc, ClienteState>(
            bloc: _clienteBloc,
            listener: (context, state) {
              if (state is ClienteSearchSuccessState) {
                _clientes = state.clientes;
                List<String> nomes = state.clientes
                    .take(5)
                    .map((cliente) => cliente.nome!)
                    .toList();
                if (_dropdownNomeClientes != nomes) {
                  setState(() {
                    _dropdownNomeClientes = nomes;
                  });
                }
              }
            },
            child: CustomSearchDropDown(
              label: "Nome do Cliente*",
              dropdownValues: _dropdownNomeClientes,
              maxLength: 40,
              valueNotifier: _clienteForm.nome,
              validator: _clienteValidator.byField(
                  _clienteForm, ErrorCodeKey.nomeESobrenome.name),
              onChanged: _onNomeClienteChanged,
              onSelected: _getClienteId,
            ),
          ),
          Visibility(
              visible: widget.isClientAndService,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          hint: "(99) 9999-9999",
                          label: "Telefone Fixo**",
                          type: TextInputType.phone,
                          maxLength: 14,
                          hide: true,
                          rightPadding: 8,
                          masks: InputMasks.maskTelefoneFixo,
                          valueNotifier: _clienteForm.telefoneFixo,
                          validator: _clienteValidator.byField(
                              _clienteForm, ErrorCodeKey.telefones.name),
                          onChanged: _clienteForm.setTelefoneFixo,
                        ),
                      ),
                      Expanded(
                        child: CustomTextFormField(
                          hint: "(99) 99999-9999",
                          label: "Telefone Celular**",
                          type: TextInputType.phone,
                          maxLength: 15,
                          hide: true,
                          leftPadding: 0,
                          masks: InputMasks.maskCelular,
                          valueNotifier: _clienteForm.telefoneCelular,
                          validator: _clienteValidator.byField(
                              _clienteForm, ErrorCodeKey.telefones.name),
                          onChanged: _clienteForm.setTelefoneCelular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: BlocListener<EnderecoBloc, EnderecoState>(
                          bloc: _enderecoBloc,
                          listener: (context, state) {
                            if (state is EnderecoSuccessState) {
                              _clienteForm.setBairro(state.bairro);
                              _clienteForm.setRua(state.rua);
                              _clienteForm.setMunicipio(state.municipio);
                              _municipioController.text = state.municipio;
                            }
                          },
                          child: CustomTextFormField(
                            hint: "00000-000",
                            label: "CEP",
                            rightPadding: 8,
                            type: TextInputType.number,
                            maxLength: 9,
                            hide: true,
                            masks: InputMasks.maskCep,
                            valueNotifier: _clienteForm.cep,
                            validator: _clienteValidator.byField(
                                _clienteForm, ErrorCodeKey.cep.name),
                            onChanged: _fetchInformationAboutCep,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomSearchDropDown(
                          label: "Município*",
                          dropdownValues: Constants.municipios,
                          leftPadding: 0,
                          maxLength: 20,
                          controller: _municipioController,
                          valueNotifier: _clienteForm.municipio,
                          validator: _clienteValidator.byField(
                              _clienteForm, ErrorCodeKey.municipio.name),
                          onChanged: _clienteForm.setMunicipio,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    hint: "Bairro...",
                    label: "Bairro*",
                    type: TextInputType.text,
                    maxLength: 255,
                    hide: true,
                    valueNotifier: _clienteForm.bairro,
                    validator: _clienteValidator.byField(
                        _clienteForm, ErrorCodeKey.bairro.name),
                    onChanged: _clienteForm.setBairro,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextFormField(
                          hint: "Rua...",
                          label: "Rua*",
                          rightPadding: 8,
                          type: TextInputType.text,
                          maxLength: 255,
                          hide: true,
                          valueNotifier: _clienteForm.rua,
                          validator: _clienteValidator.byField(
                              _clienteForm, ErrorCodeKey.rua.name),
                          onChanged: _clienteForm.setRua,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CustomTextFormField(
                          hint: "Número...",
                          label: "Número*",
                          leftPadding: 0,
                          type: TextInputType.number,
                          maxLength: 10,
                          hide: true,
                          valueNotifier: _clienteForm.numero,
                          validator: _clienteValidator.byField(
                              _clienteForm, ErrorCodeKey.numero.name),
                          onChanged: _clienteForm.setNumero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    hint: "Complemento...",
                    label: "Complemento",
                    type: TextInputType.text,
                    maxLength: 255,
                    hide: false,
                    valueNotifier: _clienteForm.complemento,
                    validator: _clienteValidator.byField(
                        _clienteForm, ErrorCodeKey.complemento.name),
                    onChanged: _clienteForm.setComplemento,
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildServiceForm() {
    return Form(
      key: _servicoFormKey,
      child: Column(
        children: [
          CustomSearchDropDown(
            label: "Equipamento*",
            dropdownValues: Constants.equipamentos,
            valueNotifier: _servicoForm.equipamento,
            hide: true,
            validator: _servicoValidator.byField(
                _servicoForm, ErrorCodeKey.equipamento.name),
            onChanged: _servicoForm.setEquipamento,
            enabled: _isInputEnabled(),
          ),
          CustomSearchDropDown(
            dropdownValues: Constants.marcas,
            valueNotifier: _servicoForm.marca,
            label: "Marca*",
            hide: true,
            validator: _servicoValidator.byField(
                _servicoForm, ErrorCodeKey.marca.name),
            onChanged: _servicoForm.setMarca,
            enabled: _isInputEnabled(),
          ),
          CustomDropdownField(
            dropdownValues: Constants.filiais,
            valueNotifier: _servicoForm.filial,
            label: "Filial*",
            validator: _servicoValidator.byField(
                _servicoForm, ErrorCodeKey.filial.name),
            onChanged: _servicoForm.setFilial,
            enabled: _isInputEnabled(),
          ),
          BlocListener<TecnicoBloc, TecnicoState>(
            bloc: _tecnicoBloc,
            listener: (context, state) {
              if (state is TecnicoSearchSuccessState) {
                _tecnicos = state.tecnicos;
                List<String> nomes = state.tecnicos
                    .take(5)
                    .map((tecnico) => "${tecnico.nome!} ${tecnico.sobrenome}")
                    .toList();
                if (_dropdownNomeTecnicos != nomes) {
                  setState(() {
                    _dropdownNomeTecnicos = nomes;
                  });
                }
              }
            },
            child: ValueListenableBuilder(
                valueListenable: _servicoForm.equipamento,
                builder: (context, value, child) {
                  bool isFieldEnabled = (value.isNotEmpty &&
                      (widget.isClientAndService ||
                          _servicoForm.idCliente.value != null));
                  if (widget.isClientAndService) {
                    isFieldEnabled = (value.isNotEmpty ||
                        (!widget.isClientAndService ||
                            _servicoForm.idCliente.value != null));
                  }

                  return CustomSearchDropDown(
                    label: "Nome do Técnico*",
                    dropdownValues: _dropdownNomeTecnicos,
                    maxLength: 50,
                    hide: false,
                    controller: _nomeTecnicoController,
                    valueNotifier: _servicoForm.nomeTecnico,
                    validator: _servicoValidator.byField(
                        _servicoForm, ErrorCodeKey.tecnico.name),
                    onChanged: _onNomeTecnicoChanged,
                    onSelected: _getTecnicoId,
                    enabled: isFieldEnabled,
                  );
                }),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: CustomDatePicker(
                  label: "Data Atendimento Previsto*",
                  hint: 'dd/mm/aaaa',
                  rightPadding: 8,
                  mask: InputMasks.maskData,
                  type: TextInputType.datetime,
                  maxLength: 10,
                  hide: true,
                  valueNotifier: _servicoForm.dataPrevista,
                  validator: _servicoValidator.byField(
                      _servicoForm, ErrorCodeKey.data.name),
                  onChanged: _servicoForm.setDataPrevista,
                  enabled: _isInputEnabled(),
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomDropdownField(
                  dropdownValues: Constants.dataAtendimento,
                  label: "Horário*",
                  leftPadding: 0,
                  valueNotifier: _servicoForm.horario,
                  validator: _servicoValidator.byField(
                      _servicoForm, ErrorCodeKey.horario.name),
                  onChanged: _servicoForm.setHorario,
                  enabled: _isInputEnabled(),
                ),
              ),
            ],
          ),
          CustomTextFormField(
            hint: "Descrição...",
            label: "Descrição*",
            type: TextInputType.multiline,
            maxLength: 255,
            maxLines: 3,
            minLines: 1,
            hide: false,
            valueNotifier: _servicoForm.descricao,
            validator: _servicoValidator.byField(
                _servicoForm, ErrorCodeKey.descricao.name),
            onChanged: _servicoForm.setDescricao,
            enabled: _isInputEnabled(),
          ),
        ],
      ),
    );
  }
}
