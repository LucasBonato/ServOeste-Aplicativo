import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/cliente/cliente_search_field.dart';
import 'package:serv_oeste/src/components/formFields/custom_text_form_field.dart';
import 'package:serv_oeste/src/components/formFields/field_labels.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/logic/endereco/endereco_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/cliente_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';
import 'package:serv_oeste/src/utils/formatters/input_masks.dart';

class ClienteFormWidget extends StatelessWidget {
  final ClienteForm clienteForm;
  final ClienteBloc bloc;
  final bool isUpdate;
  final bool isClientAndService;
  final bool isCreateCliente;
  final bool isJustShowFields;
  final bool shouldBuildButton;
  final String submitText;
  final ClienteValidator? validator;
  final TextEditingController? nomeController;
  final String Function(ClienteState)? getSuccessMessage;
  final GlobalKey<FormState>? formKey;
  final void Function() onSubmit;
  final bool isForListScreen;

  const ClienteFormWidget({
    super.key,
    required this.clienteForm,
    required this.bloc,
    required this.submitText,
    required this.onSubmit,
    this.getSuccessMessage,
    this.nomeController,
    this.isUpdate = false,
    this.shouldBuildButton = true,
    this.isClientAndService = false,
    this.isCreateCliente = false,
    this.isJustShowFields = false,
    this.formKey,
    this.validator,
    this.isForListScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = this.formKey ?? GlobalKey<FormState>();
    final ClienteValidator validator = this.validator ?? ClienteValidator();
    final TextEditingController municipioController = TextEditingController();
    final EnderecoBloc enderecoBloc = context.read<EnderecoBloc>();

    void fetchInformationAboutCep(String? cep) async {
      if (cep?.length != 9) return;
      clienteForm.setCep(cep);
      enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
    }

    return BaseEntityForm<ClienteBloc, ClienteState>(
      bloc: bloc,
      formKey: formKey,
      submitText: submitText,
      isLoading: (state) => state is ClienteLoadingState,
      isSuccess: (state) => isUpdate
          ? state is ClienteUpdateSuccessState
          : state is ClienteRegisterSuccessState,
      getSuccessMessage: getSuccessMessage,
      isError: (state) => state is ClienteErrorState,
      getErrorMessage: (state) =>
          state is ClienteErrorState ? state.error.detail : "Erro desconhecido",
      onError: (state) {
        if (state is ClienteErrorState) {
          validator.applyBackendError(state.error);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            formKey.currentState?.validate();
          });
        }
      },
      shouldBuildButton: shouldBuildButton,
      onSubmit: () async {
        validator.cleanExternalErrors();
        formKey.currentState?.validate();
        final result = validator.validate(clienteForm);
        if (!result.isValid) return;

        onSubmit();
      },
      buildFields: () => [
        ClienteSearchField(
          label: "Nome*",
          clienteBloc: bloc,
          controller: nomeController,
          listenTo: [clienteForm.nome],
          onChanged: clienteForm.setNome,
          validator:
              validator.byField(clienteForm, ErrorCodeKey.nomeESobrenome.name),
          enabled: !isJustShowFields,
          isForListScreen: isForListScreen,
        ),
        if (isCreateCliente && !isJustShowFields)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Transform.translate(
              offset: Offset(24, 0),
              child: Text(
                "Obs. os nomes que aparecerem já estão cadastrados",
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.width * 0.04)
                      .clamp(9.0, 13.0),
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        TextFormInputField(
          shouldExpand: true,
          hint: "(99) 9999-9999",
          label: "Telefone Fixo**",
          keyboardType: TextInputType.phone,
          mask: InputMasks.telefoneFixo,
          valueNotifier: clienteForm.telefoneFixo,
          enableValueNotifierSync: false,
          validator:
              validator.byField(clienteForm, ErrorCodeKey.telefones.name),
          onChanged: clienteForm.setTelefoneFixo,
          enabled: !isJustShowFields,
        ),
        TextFormInputField(
          shouldExpand: true,
          hint: "(99) 99999-9999",
          label: "Telefone Celular**",
          keyboardType: TextInputType.phone,
          maxLength: 15,
          mask: InputMasks.telefoneCelular,
          valueNotifier: clienteForm.telefoneCelular,
          enableValueNotifierSync: false,
          validator:
              validator.byField(clienteForm, ErrorCodeKey.telefones.name),
          onChanged: clienteForm.setTelefoneCelular,
          enabled: !isJustShowFields,
        ),
        Wrap(
          runSpacing: 8,
          children: [
            if (!isJustShowFields)
              BlocListener<EnderecoBloc, EnderecoState>(
                bloc: enderecoBloc,
                listener: (context, state) {
                  if (state is EnderecoSuccessState) {
                    clienteForm.setBairro(state.bairro);
                    clienteForm.setRua(state.rua);
                    clienteForm.setMunicipio(state.municipio);
                    municipioController.text = state.municipio;
                  }
                },
                child: CustomTextFormField(
                  hint: "00000-000",
                  label: "CEP",
                  type: TextInputType.number,
                  maxLength: 9,
                  hide: true,
                  leftPadding: 4,
                  rightPadding: 4,
                  masks: InputMasks.cep,
                  valueNotifier: clienteForm.cep,
                  validator:
                      validator.byField(clienteForm, ErrorCodeKey.cep.name),
                  onChanged: fetchInformationAboutCep,
                ),
              ),
            CustomSearchDropDownFormField(
              label: "Município*",
              dropdownValues: Constants.municipios,
              maxLength: 20,
              controller: municipioController,
              valueNotifier: clienteForm.municipio,
              validator:
                  validator.byField(clienteForm, ErrorCodeKey.municipio.name),
              onChanged: clienteForm.setMunicipio,
              rightPadding: 4,
              leftPadding: 4,
              enabled: !isJustShowFields,
            ),
          ],
        ),
        TextFormInputField(
          hint: "Bairro...",
          label: "Bairro*",
          keyboardType: TextInputType.text,
          maxLength: 255,
          valueNotifier: clienteForm.bairro,
          validator: validator.byField(clienteForm, ErrorCodeKey.bairro.name),
          onChanged: clienteForm.setBairro,
          enabled: !isJustShowFields,
        ),
        TextFormInputField(
          shouldExpand: true,
          flex: 5,
          hint: "Rua...",
          label: "Rua*",
          keyboardType: TextInputType.text,
          maxLength: 255,
          valueNotifier: clienteForm.rua,
          validator: validator.byField(clienteForm, ErrorCodeKey.rua.name),
          onChanged: clienteForm.setRua,
          enabled: !isJustShowFields,
        ),
        TextFormInputField(
          shouldExpand: true,
          flex: 2,
          hint: "Número...",
          label: "Número*",
          keyboardType: TextInputType.text,
          maxLength: 10,
          valueNotifier: clienteForm.numero,
          validator: validator.byField(clienteForm, ErrorCodeKey.numero.name),
          onChanged: clienteForm.setNumero,
          enabled: !isJustShowFields,
        ),
        TextFormInputField(
          hint: "Complemento...",
          label: "Complemento",
          keyboardType: TextInputType.text,
          maxLength: 255,
          valueNotifier: clienteForm.complemento,
          validator:
              validator.byField(clienteForm, ErrorCodeKey.complemento.name),
          onChanged: clienteForm.setComplemento,
          enabled: !isJustShowFields,
        ),
        if (shouldBuildButton)
          const Padding(
              padding: EdgeInsets.only(left: 16), child: BuildFieldLabels()),
      ],
    );
  }
}
