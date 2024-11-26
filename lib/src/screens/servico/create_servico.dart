import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lucid_validation/lucid_validation.dart';
import 'package:serv_oeste/src/components/custom_text_form_field.dart';
import 'package:serv_oeste/src/logic/servico/servico_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/cliente/cliente_request.dart';
import 'package:serv_oeste/src/models/error/error_entity.dart';
import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/models/servico/servico_request.dart';
import 'package:serv_oeste/src/models/servico/tecnico_disponivel.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/validators/validator.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/components/date_picker.dart';
import 'package:serv_oeste/src/components/search_dropdown_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';

import '../../components/dropdown_field.dart';

class CreateServico extends StatefulWidget {
  final bool isWithAnExistingClient;
  final int? clientId;

  const CreateServico({
    super.key,
    this.clientId,
    this.isWithAnExistingClient = false,
  });

  @override
  State<CreateServico> createState() => _CreateServicoState();
}

class _CreateServicoState extends State<CreateServico>{
  final TecnicoBloc _tecnicoBloc = TecnicoBloc();
  late List<Tecnico> _tecnicos;
  List<String> _dropdownTecnicoValuesNomes = [];

  Timer? _debounce;

  final ServicoBloc _servicoBloc = ServicoBloc();
  final ServicoForm _servicoCreateForm = ServicoForm();
  final ServicoValidator _servicoCreateValidator = ServicoValidator();
  final GlobalKey<FormState> _servicoFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final ClienteBloc _clienteBloc = ClienteBloc();
  final ClienteForm _clienteCreateForm = ClienteForm();
  final ClienteValidator _clienteCreateValidator = ClienteValidator();
  List<String> _dropdownClienteValuesNomes = [];

  late final EnderecoBloc _enderecoBloc = EnderecoBloc();


  late int dayOfTheWeek;

  TextStyle textStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isWithAnExistingClient) {
      _servicoCreateForm.setIdCliente(widget.clientId);
    }

    dayOfTheWeek = DateTime.now().weekday;
  }

  @override
  void dispose() {
    _enderecoBloc.close();
    _clienteBloc.close();
    _servicoBloc.close();
    _tecnicoBloc.close();
    _debounce?.cancel();
    super.dispose();
  }

  void _onNomeClienteChanged(String nome) {
    if (_debounce?.isActive?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 150), () => _fetchClienteNames(nome));
  }

  void _fetchClienteNames(String nome) {
    _clienteCreateForm.setNome(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownClienteValuesNomes.isEmpty) return;
    _clienteBloc.add(ClienteSearchEvent(nome: nome));
  }

  void _onNomeTecnicoChanged(String nome) {
    _servicoCreateForm.setIdTecnico(null);
    if (_servicoCreateForm.equipamento.value.isEmpty) return;
    if (_debounce?.isActive?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 150), () => _fetchTecnicoNames(nome));
  }

  void _fetchTecnicoNames(String nome) {
    _servicoCreateForm.setNomeTecnico(nome);
    if (nome == "") return;
    if (nome.split(" ").length > 1 && _dropdownTecnicoValuesNomes.isEmpty) return;
    _tecnicoBloc.add(TecnicoSearchEvent(nome: nome));

    // _idTecnicoSelected = null;
  }

  void _getTecnicoId(String nome) {
    _servicoCreateForm.setNomeTecnico(nome);
    for(Tecnico tecnico in _tecnicos) {
      if("${tecnico.nome!} ${tecnico.sobrenome!}" == _servicoCreateForm.nomeTecnico.value) {
        _servicoCreateForm.setIdTecnico(tecnico.id);
      }
    }
  }

  void _fetchInformationAboutCep(String? cep) {
    if(cep?.length != 9) return;
    _clienteCreateForm.setCep(cep);
    _enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
  }

  bool _isClienteValidForm() {
    _clienteFormKey.currentState?.validate();
    return _clienteCreateValidator.validate(_clienteCreateForm).isValid;
  }

  bool _isServicoValidForm() {
    _servicoFormKey.currentState?.validate();
    ValidationResult result = _servicoCreateValidator.validate(_servicoCreateForm);
    return result.isValid;
  }

  void _fetchTecnicosDisponiveis() {
    // ServicoService servicoService = ServicoService();
    // List<TecnicoDisponivel> tecnicos = await servicoService.getTecnicosDisponiveis();
    // setState(() {
    //   _tecnicos = tecnicos;
    //   isTecnicosLoading = false;
    // });
  }

  void _registerServicoAndCliente() {
    if(_isClienteValidForm() == false) {
      return;
    }

    if(_isServicoValidForm() == false) {
      return;
    }

    List<String> nomes = _clienteCreateForm.nome.value.split(" ");
    _clienteCreateForm.nome.value = nomes.first;
    String sobrenomeCliente = nomes
        .sublist(1)
        .join(" ")
        .trim();

    _servicoBloc.add(ServicoRegisterPlusClientEvent(
      cliente: ClienteRequest.fromClienteForm(cliente: _clienteCreateForm, sobrenome: sobrenomeCliente),
      servico: ServicoRequest.fromServicoForm(servico: _servicoCreateForm)
    ));
    _clienteCreateForm.nome.value = "${nomes.first} $sobrenomeCliente";
  }

  void _registerServicoForACliente() {
    if(_isServicoValidForm() == false) {
      return;
    }

    _servicoBloc.add(ServicoRegisterEvent(servico: ServicoRequest.fromServicoForm(servico: _servicoCreateForm)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, ""),
        ),
        title: const Text("Novo Serviço"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Visibility(
                visible: !widget.isWithAnExistingClient,
                child: Column(
                  children: [
                    Form(
                      key: _clienteFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BlocListener<ClienteBloc, ClienteState>(
                            bloc: _clienteBloc,
                            listener: (context, state) {
                              if (state is ClienteSearchSuccessState) {
                                List<String> nomes = state.clientes
                                    .take(5)
                                    .map((cliente) => cliente.nome!)
                                    .toList();

                                if(_dropdownClienteValuesNomes != nomes) {
                                  _dropdownClienteValuesNomes = nomes;
                                  setState(() {});
                                }
                              }
                            },
                            child: CustomSearchDropDown(
                              label: "Nome",
                              maxLength: 40,
                              onChanged: _onNomeClienteChanged,
                              onSelected: _onNomeClienteChanged,
                              dropdownValues: _dropdownClienteValuesNomes,
                              validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.nomeESobrenome.name),
                            ),
                          ),
                          CustomTextFormField(
                            valueNotifier: _clienteCreateForm.telefoneCelular,
                            hint: "(99) 99999-9999",
                            label: "Telefone Celular",
                            masks: Constants.maskTelefone,
                            maxLength: 15,
                            type: TextInputType.phone,
                            hide: false,
                            validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.telefoneCelular.name),
                            onChanged: _clienteCreateForm.setTelefoneCelular,
                          ),  // Telefone Celular
                          CustomTextFormField(
                            valueNotifier: _clienteCreateForm.telefoneFixo,
                            hint: "(99) 99999-9999",
                            label: "Telefone Fixo",
                            masks: Constants.maskTelefone,
                            maxLength: 15,
                            type: TextInputType.phone,
                            hide: false,
                            validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.telefoneFixo.name),
                            onChanged: _clienteCreateForm.setTelefoneFixo,
                          ),  // Telefone Fixo
                          BlocListener<EnderecoBloc, EnderecoState>(
                            bloc: _enderecoBloc,
                            listener: (context, state) {
                              if (state is EnderecoSuccessState) {
                                _clienteCreateForm.setEndereco(state.endereco!);
                                _clienteCreateForm.setMunicipio(state.municipio!);
                                _clienteCreateForm.setBairro(state.bairro!);
                              }
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: CustomTextFormField(
                                        valueNotifier: _clienteCreateForm.cep,
                                        hint: "00000-000",
                                        label: "CEP",
                                        hide: true,
                                        maxLength: 9,
                                        masks: Constants.maskCep,
                                        rightPadding: 4,
                                        type: TextInputType.number,
                                        validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.cep.name),
                                        onChanged: _fetchInformationAboutCep,
                                      ),
                                    ), // CEP
                                    Expanded(
                                      flex: 8,
                                      child: CustomTextFormField(
                                        valueNotifier: _clienteCreateForm.endereco,
                                        hint: "Rua...",
                                        label: "Endereço, Número e Complemento",
                                        validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.endereco.name),
                                        maxLength: 255,
                                        hide: true,
                                        type: TextInputType.text,
                                        leftPadding: 4,
                                        onChanged: _clienteCreateForm.setEndereco,
                                      ),
                                    ), // Endereço
                                  ],
                                ),
                                CustomDropdownField(
                                  label: "Município",
                                  dropdownValues: Constants.municipios,
                                  valueNotifier: _clienteCreateForm.municipio,
                                  validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.municipio.name),
                                  onChanged: _clienteCreateForm.setMunicipio,
                                ),
                                CustomTextFormField(
                                  valueNotifier: _clienteCreateForm.bairro,
                                  hint: "Bairro...",
                                  label: "Bairro",
                                  validator: _clienteCreateValidator.byField(_clienteCreateForm, ErrorCodeKey.bairro.name),
                                  maxLength: 255,
                                  hide: true,
                                  type: TextInputType.text,
                                  onChanged: _clienteCreateForm.setBairro,
                                ), // Bairro
                              ],
                            ),
                          ),
                        ]
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.032,
                          right: MediaQuery.of(context).size.width * 0.032,
                          bottom: 8
                      ),
                      child: const Divider(),
                    ),
                  ],
                )
              ), // Cliente Form

              Form(
                key: _servicoFormKey,
                child: Column(
                  children: [
                    CustomSearchDropDown(
                      label: "Equipamento",
                      maxLength: 80,
                      dropdownValues: Constants.equipamentos,
                      onChanged: _servicoCreateForm.setEquipamento,
                      onSelected: _servicoCreateForm.setEquipamento,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.equipamento.name),
                    ),
                    CustomSearchDropDown(
                      label: "Marca",
                      maxLength: 40,
                      hide: true,
                      dropdownValues: Constants.marcas,
                      onChanged: _servicoCreateForm.setMarca,
                      onSelected: _servicoCreateForm.setMarca,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.marca.name),
                    ),
                    CustomDropdownField(
                      label: "Filial",
                      dropdownValues: Constants.filiais,
                      valueNotifier: _servicoCreateForm.filial,
                      onChanged: _servicoCreateForm.setFilial,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.filial.name),
                    ),
                    CustomDatePicker(
                      label: "Data Atendimento Previsto",
                      hint: "",
                      mask: Constants.maskData,
                      type: TextInputType.datetime,
                      maxLength: 10,
                      hide: true,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.data.name),
                      valueNotifier: _servicoCreateForm.dataAtendimentoPrevisto,
                    ),
                    CustomDropdownField(
                      label: "Horário Previsto",
                      dropdownValues: Constants.dataAtendimento,
                      valueNotifier: _servicoCreateForm.horarioPrevisto,
                      onChanged: _servicoCreateForm.setHorarioPrevisto,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.horario.name),
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

                          if(_dropdownTecnicoValuesNomes != nomes) {
                            _dropdownTecnicoValuesNomes = nomes;
                            setState(() {});
                          }
                        }
                      },
                      child: CustomSearchDropDown(
                        label: "Técnico",
                        maxLength: 40,
                        onChanged: _onNomeTecnicoChanged,
                        onSelected: _getTecnicoId,
                        dropdownValues: _dropdownTecnicoValuesNomes,
                        validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.tecnico.name),
                      ),
                    ),
                    CustomTextFormField(
                      hint: "Descrição...",
                      label: "Descrição",
                      masks: [],
                      maxLength: 200,
                      maxLines: 5,
                      type: TextInputType.text,
                      valueNotifier: _servicoCreateForm.descricao,
                      onChanged: _servicoCreateForm.setDescricao,
                      hide: false,
                      validator: _servicoCreateValidator.byField(_servicoCreateForm, ErrorCodeKey.descricao.name),
                    ),
                    Column(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _servicoCreateForm.equipamento,
                          builder: (context, value, child) {
                            bool isButtonEnabled = value.isNotEmpty;

                            return ElevatedButton(
                              onPressed: (isButtonEnabled)
                                  ? () => _showDialog(context)
                                  : null,
                              style: TextButton.styleFrom(
                                fixedSize: Size(MediaQuery.of(context).size.width * 0.80, 48),
                                backgroundColor: (isButtonEnabled) ? Colors.blueAccent : Colors.grey,
                                foregroundColor: (isButtonEnabled) ? Colors.white : Colors.black26,
                                shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  )
                              ),
                              child: const Text("Verificar disponibilidade", style: TextStyle(fontSize: 20))
                            );
                          },
                        ),
                        Divider(
                          height: MediaQuery.of(context).size.height * 0.01,
                          thickness: 0,
                          color: Colors.transparent
                        ),
                        BlocListener<ServicoBloc, ServicoState>(
                          bloc: _servicoBloc,
                          listener: (context, state) {
                            if (state is ServicoRegisterSuccessState) {
                              Navigator.pop(context);
                            }
                            else if (state is ServicoErrorState) {
                              ErrorEntity error = state.error;

                              if (!widget.isWithAnExistingClient) {
                                _clienteCreateValidator.applyBackendError(error);
                                _clienteFormKey.currentState?.validate();
                                _clienteCreateValidator.cleanExternalErrors();
                              }

                              _servicoCreateValidator.applyBackendError(error);
                              _servicoFormKey.currentState?.validate();
                              _servicoCreateValidator.cleanExternalErrors();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("[ERROR] Informação(ões) inválida(s) ao registrar o Serviço: ${error.errorMessage}"))
                              );
                            }
                          },
                          child: ElevatedButton(
                            onPressed: () => (widget.isWithAnExistingClient) ? _registerServicoForACliente() : _registerServicoAndCliente(),
                            style: TextButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.80, 48),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              )
                            ),
                            child: const Text("Cadastrar novo serviço", style: TextStyle(fontSize: 20))
                          )
                        ),
                      ],
                    )
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  String dayOfTheWeekString(int day) {
    return switch (day) {
      1 || 7 => "Segunda",
      2 || 8 => "Terça",
      3 || 9 => "Quarta",
      4 => "Quinta",
      5 => "Sexta",
      6 => "Sábado",
      _ => "Domingo"
    };
  }

  Table _buildTableWithData()  {

    //if(_tecnicos.isEmpty) {
    if([].isEmpty) {
      return Table(
        border: TableBorder.all(
          style: BorderStyle.solid,
          width: 2,
          color: Colors.black
        ),
        children: [
          TableRow(
            children: [
              TableCell(child: Text("Nenhum técnico ocupado!", textAlign: TextAlign.center, style: textStyle))
            ]
          )
        ],
      );
    }

    return Table(
      columnWidths: const <int, TableColumnWidth> {
        0: FlexColumnWidth(2)
      },
      border: TableBorder.all(
          color: Colors.black,
          width: 2
      ),
      //children: construirLinhasTecnicos(_tecnicos, dayOfTheWeek, 5),
      children: construirLinhasTecnicos([], dayOfTheWeek, 5),
    );
  }

  Map<String, int> calcularDias(int dayOfTheWeek, List<Disponibilidade> disponibilidades) {
    Map<String, int> dias = {
      "total": 0,
      "${dayOfTheWeekString(dayOfTheWeek)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek)}T": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 1)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 1)}T": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 2)}M": 0,
      "${dayOfTheWeekString(dayOfTheWeek + 2)}T": 0,
    };

    for (Disponibilidade disponibilidade in disponibilidades) {
      String key = "${dayOfTheWeekString(disponibilidade.dia!)}${disponibilidade.periodo!.substring(0, 1).toUpperCase()}";
      dias[key] = disponibilidade.quantidade!;
      dias["total"] = dias["total"]! + disponibilidade.quantidade!;
    }

    return dias;
  }

  List<TableRow> construirLinhasTecnicos(List<TecnicoDisponivel> tecnicos, int dayOfTheWeek, int quantidadeLimiteDeLinhas) {
    // Ordena os técnicos pelo total de quantidades, do maior para o menor
    tecnicos.sort((a, b) {
      int totalA = a.disponibilidades!.fold(0, (prev, element) => prev + element.quantidade!);
      int totalB = b.disponibilidades!.fold(0, (prev, element) => prev + element.quantidade!);
      return totalB.compareTo(totalA); // Maior para menor
    });

    List<TableRow> tecnicosDisponiveis = [];
    for (int i = 0; i < tecnicos.length && i < quantidadeLimiteDeLinhas; i++) {
      TecnicoDisponivel tecnico = tecnicos[i];
      Map<String, int> dias = calcularDias(dayOfTheWeek, tecnico.disponibilidades!);

      int id = tecnico.id!;
      String nome = tecnico.nome!;

      tecnicosDisponiveis.add(
        TableRow(
          children: [
            TableCell(
              child: Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 0, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek)}M"]}", style: textStyle, textAlign: TextAlign.center),
              ),
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 0, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
              child: GestureDetector(
                onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 1, nome),
                child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 1)}M"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 1, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 1)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 2, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 2)}M"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
            TableCell(
                child: GestureDetector(
                  onDoubleTap: () => _changeInformationOnTheFormFromTable(id, 2, nome),
                  child: Text("${dias["${dayOfTheWeekString(dayOfTheWeek + 2)}T"]}", style: textStyle, textAlign: TextAlign.center),
              )
            ),
          ],
        ),
      );
    }

    return tecnicosDisponiveis;
  }

  void _changeInformationOnTheFormFromTable(int id, int daysToAdd, String nome) {
    String dataAtendimento = "${dataFormated(daysToAdd)}/${DateTime.now().year}";
    setState(() {
      _servicoCreateForm.setIdTecnico(id);
      _servicoCreateForm.setNomeTecnico(nome);
      _servicoCreateForm.setDataAtendimentoPrevisto(dataAtendimento);
    });
    Navigator.pop(context);
  }

  String dataFormated(int daysToAdd) {
    DateTime diaAtual = DateTime.now();
    int addedDays = 0;

    if(dayOfTheWeek == DateTime.sunday) {
      diaAtual = diaAtual.add(const Duration(days: 1));
    }

    while (addedDays < daysToAdd) {
      diaAtual = diaAtual.add(const Duration(days: 1));
      if (diaAtual.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    String formattedDate = "${diaAtual.day.toString().padLeft(2, '0')}/${diaAtual.month.toString().padLeft(2, '0')}";
    return formattedDate;
  }
  
  Table _tableDias() {
    return Table(
      border: TableBorder.all(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        color: Colors.black,
        width: 2
      ),
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text("Técnicos", textAlign: TextAlign.center, style: textStyle)
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(0), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek), style: textStyle),
                ],
              )
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(1), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek + 1), style: textStyle),
                ],
              )
            ),
            TableCell(
              child: Column(
                children: [
                  Text(dataFormated(2), style: textStyle),
                  Text(dayOfTheWeekString(dayOfTheWeek + 2), style: textStyle),
                ],
              )
            ),
          ]
        ),
      ],
    );
  }

  Future _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Container(
          margin: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height * .35,
          child: Column(
            children: [
              _tableDias(),
              Table(
                border: TableBorder.all(
                  color: Colors.black,
                  width: 2
                ),
                columnWidths: const <int, TableColumnWidth> {
                  0: IntrinsicColumnWidth(flex: 2)
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text("")
                      ),
                      TableCell(
                        child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                        child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("M", style: textStyle, textAlign: TextAlign.center)
                      ),
                      TableCell(
                          child: Text("T", style: textStyle, textAlign: TextAlign.center)
                      ),
                    ]
                  )
                ],
              ),
              _buildTableWithData(),
              const Text("Clique duas vezes em um dos números para puxar as informações do técnico para o formulário", textAlign: TextAlign.center, )
            ],
          ),
        ),
      )
    );
  }
}
