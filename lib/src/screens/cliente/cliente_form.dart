import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClienteFormPage extends StatelessWidget {
  final String title;
  final String submitText;
  final ClienteBloc bloc;
  final ClienteForm clienteForm;
  final void Function() onSubmit;
  final TextEditingController? nomeController;
  final bool isUpdate;
  final bool skeleton;

  const ClienteFormPage({
    super.key,
    required this.title,
    required this.submitText,
    required this.bloc,
    required this.clienteForm,
    required this.onSubmit,
    this.nomeController,
    this.isUpdate = false,
    this.skeleton = false
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final EnderecoBloc enderecoBloc = EnderecoBloc();
    final ClienteValidator validator = ClienteValidator();
    final Debouncer debouncer = Debouncer();
    final ValueNotifier<List<String>> nomes = ValueNotifier<List<String>>([]);
    final TextEditingController municipioController = TextEditingController();

    void fetchClienteNames(String nome) async {
      clienteForm.setNome(nome);
      if (nome == "") return;
      if (nome.split(" ").length > 1 && nomes.value.isEmpty) return;
      bloc.add(ClienteSearchEvent(nome: nome));
    }

    void fetchInformationAboutCep(String? cep) async {
      if (cep?.length != 9) return;
      clienteForm.setCep(cep);
      enderecoBloc.add(EnderecoSearchCepEvent(cep: cep!));
    }

    return BaseFormScreen(
      title: title,
      shouldActivateEvent: isUpdate,
      child: Skeletonizer(
        enabled: skeleton,
        child: BaseEntityForm<ClienteBloc, ClienteState>(
          bloc: bloc,
          formKey: formKey,
          submitText: submitText,
          isLoading: (state) => state is ClienteLoadingState,
          isSuccess: (state) => isUpdate ? state is ClienteUpdateSuccessState : state is ClienteRegisterSuccessState,
          isError: (state) => state is ClienteErrorState,
          getErrorMessage: (state) => state is ClienteErrorState ? state.error.errorMessage : "Erro desconhecido",
          onSubmit: () async {
            formKey.currentState?.validate();
            final result = validator.validate(clienteForm);
            if (!result.isValid) return;

            onSubmit();
          },
          buildFields: () => [
            BlocListener<ClienteBloc, ClienteState>(
              bloc: bloc,
              listener: (context, state) {
                if (state is ClienteSearchSuccessState) {
                  nomes.value = state.clientes
                      .take(5)
                      .map((cliente) => cliente.nome!)
                      .toList();
                }
              },
              child: ValueListenableBuilder<List<String>>(
                valueListenable: nomes,
                builder: (context, nomesList, _) {
                  return CustomSearchDropDownFormField(
                    leftPadding: 4,
                    rightPadding: 4,
                    label: "Nome*",
                    controller: nomeController,
                    dropdownValues: nomesList,
                    validator: validator.byField(clienteForm, ErrorCodeKey.nomeESobrenome.name),
                    onChanged: (nome) => debouncer.execute(() => fetchClienteNames(nome)),
                  );
                },
              ),
            ),
            TextFormInputField(
              shouldExpand: true,
              hint: "(99) 9999-9999",
              label: "Telefone Fixo**",
              keyboardType: TextInputType.phone,
              maxLength: 14,
              mask: InputMasks.telefoneFixo,
              valueNotifier: clienteForm.telefoneFixo,
              validator: validator.byField(clienteForm, ErrorCodeKey.telefones.name),
              onChanged: clienteForm.setTelefoneFixo,
            ),
            TextFormInputField(
              shouldExpand: true,
              hint: "(99) 99999-9999",
              label: "Telefone Celular**",
              keyboardType: TextInputType.phone,
              maxLength: 15,
              mask: InputMasks.telefoneCelular,
              valueNotifier: clienteForm.telefoneCelular,
              validator: validator.byField(clienteForm, ErrorCodeKey.telefones.name),
              onChanged: clienteForm.setTelefoneCelular,
            ),
            Wrap(
              runSpacing: 8,
              children: [
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
                    validator: validator.byField(clienteForm, ErrorCodeKey.cep.name),
                    onChanged: fetchInformationAboutCep,
                  ),
                ),
                CustomSearchDropDownFormField(
                  label: "Município*",
                  dropdownValues: Constants.municipios,
                  maxLength: 20,
                  controller: municipioController,
                  valueNotifier: clienteForm.municipio,
                  validator: validator.byField(clienteForm, ErrorCodeKey.municipio.name),
                  onChanged: clienteForm.setMunicipio,
                  rightPadding: 4,
                  leftPadding: 4,
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
            ),
            TextFormInputField(
              hint: "Complemento...",
              label: "Complemento",
              keyboardType: TextInputType.text,
              maxLength: 255,
              valueNotifier: clienteForm.complemento,
              validator: validator.byField(clienteForm, ErrorCodeKey.complemento.name),
              onChanged: clienteForm.setComplemento,
            ),
            const Padding(padding: EdgeInsets.only(left: 16), child: BuildFieldLabels()),
          ],
        ),
      ),
    );
  }
}
