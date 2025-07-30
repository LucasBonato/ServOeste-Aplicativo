import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_grid_checkers_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/models/validators/tecnico_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';

class CreateTecnico extends StatelessWidget {
  const CreateTecnico({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TecnicoBloc bloc = context.read<TecnicoBloc>();
    final TecnicoValidator validator = TecnicoValidator();
    final TecnicoForm tecnicoForm = TecnicoForm();
    final Debouncer debouncer = Debouncer();
    final ValueNotifier<List<String>> nomes = ValueNotifier<List<String>>([]);
    final Map<String, bool> checkersMap = {
      "Adega": false,
      "Bebedouro": false,
      "Climatizador": false,
      "Cooler": false,
      "Frigobar": false,
      "Geladeira": false,
      "Lava Louça": false,
      "Lava Roupa": false,
      "Microondas": false,
      "Purificador": false,
      "Secadora": false,
      "Outros": false,
    };

    void fetchTecnicoNames(String nome) async {
      tecnicoForm.setNome(nome);
      if (nome == "") return;
      if (nome.split(" ").length > 1 && nomes.value.isEmpty) return;
      bloc.add(TecnicoSearchEvent(nome: nome));
    }

    return BaseFormScreen(
      title: "Adicionar Técnico",
      child: BaseEntityForm<TecnicoBloc, TecnicoState>(
        bloc: bloc,
        formKey: formKey,
        submitText: "Adicionar Técnico",
        isLoading: (state) => state is TecnicoLoadingState,
        isSuccess: (state) => state is TecnicoRegisterSuccessState,
        isError: (state) => state is TecnicoErrorState,
        getErrorMessage: (state) => state is TecnicoErrorState ? state.error.errorMessage : "Erro desconhecido",
        onSubmit: () async {
          checkersMap.forEach((label, isChecked) {
            int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
            if (isChecked) {
              tecnicoForm.addConhecimentos(idConhecimento);
            }
            else {
              tecnicoForm.removeConhecimentos(idConhecimento);
            }
          });

          validator.setConhecimentos(tecnicoForm.conhecimentos.value);

          formKey.currentState?.validate();
          final result = validator.validate(tecnicoForm);
          if (!result.isValid) return;

          final List<String> nomes = tecnicoForm.nome.value.split(" ");
          final String nome = nomes.first;
          final String sobrenome = nomes.sublist(1).join(" ").trim();

          tecnicoForm.setNome(nome);

          bloc.add(TecnicoRegisterEvent(
            tecnico: Tecnico.fromForm(tecnicoForm),
            sobrenome: sobrenome
          ));

          tecnicoForm.setNome("$nome $sobrenome");
        },
        buildFields: () => [
          BlocListener<TecnicoBloc, TecnicoState>(
            bloc: bloc,
            listener: (context, state) {
              if (state is TecnicoSearchSuccessState) {
                nomes.value = state.tecnicos
                    .take(5)
                    .map((tecnico) => "${tecnico.nome} ${tecnico.sobrenome}")
                    .toList();
              }
            },
            child: ValueListenableBuilder<List<String>>(
              valueListenable: nomes,
              builder: (context, nomes, _) {
                return CustomSearchDropDownFormField(
                  label: "Nome*",
                  maxLength: 40,
                  rightPadding: 4,
                  leftPadding: 4,
                  dropdownValues: nomes,
                  validator: validator.byField(tecnicoForm, ErrorCodeKey.nomeESobrenome.name),
                  onChanged: (nome) => debouncer.execute(() => fetchTecnicoNames(nome)),
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
            valueNotifier: tecnicoForm.telefoneFixo,
            validator: validator.byField(tecnicoForm, ErrorCodeKey.telefones.name),
            onChanged: tecnicoForm.setTelefoneFixo,
          ),
          TextFormInputField(
            shouldExpand: true,
            hint: "(99) 99999-9999",
            label: "Telefone Celular**",
            keyboardType: TextInputType.phone,
            maxLength: 15,
            mask: InputMasks.telefoneCelular,
            valueNotifier: tecnicoForm.telefoneCelular,
            validator: validator.byField(tecnicoForm, ErrorCodeKey.telefones.name),
            onChanged: tecnicoForm.setTelefoneCelular,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Conhecimentos*",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CustomGridCheckersFormField(
                validator: validator.byField(tecnicoForm, ErrorCodeKey.conhecimento.name),
                checkersMap: checkersMap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
