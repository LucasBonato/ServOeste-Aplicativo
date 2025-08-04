import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_grid_checkers_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/models/validators/tecnico_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/debouncer.dart';
import 'package:serv_oeste/src/shared/input_masks.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TecnicoFormPage extends StatelessWidget {
  final String title;
  final String submitText;
  final TecnicoBloc bloc;
  final TecnicoForm tecnicoForm;
  final void Function() onSubmit;
  final Map<String, bool> checkersMap;
  final TextEditingController? nomeController;
  final Map<String, String> situationMap;
  final bool isUpdate;
  final bool isSkeleton;

  const TecnicoFormPage({
    super.key,
    required this.title,
    required this.submitText,
    required this.bloc,
    required this.tecnicoForm,
    required this.onSubmit,
    required this.checkersMap,
    required this.situationMap,
    this.nomeController,
    this.isUpdate = false,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TecnicoValidator validator = TecnicoValidator();
    final Debouncer debouncer = Debouncer();
    final ValueNotifier<List<String>> nomes = ValueNotifier<List<String>>([]);
    final ValueNotifier<String> situacoes = ValueNotifier<String>(Constants.situationTecnicoList.first);

    void fetchTecnicoNames(String nome) async {
      tecnicoForm.setNome(nome);
      if (nome == "") return;
      if (nome.split(" ").length > 1 && nomes.value.isEmpty) return;
      bloc.add(TecnicoSearchEvent(nome: nome));
    }

    return BaseFormScreen(
      title: title,
      shouldActivateEvent: isUpdate,
      child: Skeletonizer(
        enabled: isSkeleton,
        child: BaseEntityForm<TecnicoBloc, TecnicoState>(
          bloc: bloc,
          formKey: formKey,
          submitText: submitText,
          isLoading: (state) => state is TecnicoLoadingState,
          isSuccess: (state) => isUpdate ? state is TecnicoUpdateSuccessState : state is TecnicoRegisterSuccessState,
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

            onSubmit();
          },
          buildFields: () => [
            Wrap(
              runSpacing: 8,
              children: [
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
                        controller: nomeController,
                        validator: validator.byField(tecnicoForm, ErrorCodeKey.nomeESobrenome.name),
                        onChanged: (nome) => debouncer.execute(() => fetchTecnicoNames(nome)),
                      );
                    },
                  ),
                ),
                if (isUpdate)
                  CustomDropdownFormField(
                    label: "Situação",
                    dropdownValues: Constants.situationTecnicoList,
                    leftPadding: 4,
                    rightPadding: 4,
                    valueNotifier: situacoes,
                    validator: validator.byField(tecnicoForm, ErrorCodeKey.situacao.name),
                    onChanged: tecnicoForm.setSituacao,
                  ),
              ],
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
            CustomGridCheckersFormField(
              title: "Conhecimentos*",
              validator: validator.byField(tecnicoForm, ErrorCodeKey.conhecimento.name),
              checkersMap: checkersMap,
            ),
          ],
        ),
      ),
    );
  }
}
