import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/cliente/cliente_bloc.dart';
import 'package:serv_oeste/src/models/cliente/cliente.dart';
import 'package:serv_oeste/src/models/cliente/cliente_form.dart';
import 'package:serv_oeste/src/screens/cliente/cliente_form.dart';

class CreateCliente extends StatelessWidget {
  const CreateCliente({super.key});

  @override
  Widget build(BuildContext context) {
    final ClienteBloc bloc = context.read<ClienteBloc>();
    final EnderecoBloc enderecoBloc = EnderecoBloc();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ClienteForm clienteForm = ClienteForm();
    final ClienteValidator validator = ClienteValidator();
    final TextEditingController municipioController = TextEditingController();
    final Debouncer debouncer = Debouncer();
    final ValueNotifier<List<String>> nomes = ValueNotifier<List<String>>([]);

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
      title: "Adicionar Cliente",
      child: BaseEntityForm<ClienteBloc, ClienteState>(
        bloc: bloc,
        formKey: formKey,
        submitText: "Adicionar Cliente",
        isLoading: (state) => state is ClienteLoadingState,
        isSuccess: (state) => state is ClienteRegisterSuccessState,
        isError: (state) => state is ClienteErrorState,
        getErrorMessage: (state) => state is ClienteErrorState ? state.error.errorMessage : "Erro desconhecido",
        onSubmit: () async {
          formKey.currentState?.validate();
          final result = validator.validate(clienteForm);
          if (!result.isValid) return;

          final List<String> nomesSplit = clienteForm.nome.value.split(" ");
          final String nome = nomesSplit.first;
          final String sobrenome = nomesSplit.sublist(1).join(" ").trim();

          clienteForm.setNome(nome);

          bloc.add(ClienteRegisterEvent(
            cliente: Cliente.fromForm(clienteForm),
            sobrenome: sobrenome,
          ));

          clienteForm.setNome("$nome $sobrenome");
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
    );
  }
}
