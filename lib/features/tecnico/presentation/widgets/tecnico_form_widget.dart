import 'package:flutter/material.dart';
import 'package:serv_oeste/core/constants/constants.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_form.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/src/components/formFields/custom_grid_checkers_form_field.dart';
import 'package:serv_oeste/src/components/formFields/dropdown_form_field.dart';
import 'package:serv_oeste/src/components/formFields/search_input_field.dart';
import 'package:serv_oeste/src/components/formFields/tecnico/tecnico_search_field.dart';
import 'package:serv_oeste/src/models/enums/error_code_key.dart';
import 'package:serv_oeste/src/models/validators/tecnico_validator.dart';
import 'package:serv_oeste/src/screens/base_entity_form.dart';
import 'package:serv_oeste/src/screens/base_form_screen.dart';
import 'package:serv_oeste/src/utils/formatters/input_masks.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TecnicoFormWidget extends StatelessWidget {
  final String title;
  final TecnicoBloc bloc;
  final TecnicoForm tecnicoForm;
  final void Function() onSubmit;
  final String submitText;
  final String successMessage;
  final Map<String, bool> checkersMap;
  final TextEditingController? nomeController;
  final Map<String, String> situationMap;
  final bool isUpdate;
  final bool isSkeleton;
  final bool isForListScreen;

  const TecnicoFormWidget({
    super.key,
    required this.title,
    required this.bloc,
    required this.tecnicoForm,
    required this.onSubmit,
    required this.submitText,
    required this.successMessage,
    required this.checkersMap,
    required this.situationMap,
    this.nomeController,
    this.isUpdate = false,
    this.isSkeleton = false,
    this.isForListScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TecnicoValidator validator = TecnicoValidator();
    final ValueNotifier<String> situacoes = ValueNotifier<String>(Constants.situationTecnicoList.first);

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
          getSuccessMessage: (state) {
            return successMessage;
          },
          isError: (state) => state is TecnicoErrorState,
          getErrorMessage: (state) => state is TecnicoErrorState ? state.error.detail : "Erro desconhecido",
          onError: (state) {
            if (state is TecnicoErrorState) {
              validator.applyBackendError(state.error);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                formKey.currentState?.validate();
              });
            }
          },
          onSubmit: () async {
            checkersMap.forEach((label, isChecked) {
              int idConhecimento = (checkersMap.keys.toList().indexOf(label) + 1);
              if (isChecked) {
                tecnicoForm.addConhecimentos(idConhecimento);
              } else {
                tecnicoForm.removeConhecimentos(idConhecimento);
              }
            });

            validator.setConhecimentos(tecnicoForm.conhecimentos.value);

            validator.cleanExternalErrors();
            formKey.currentState?.validate();
            final result = validator.validate(tecnicoForm);
            if (!result.isValid) return;

            onSubmit();
          },
          buildFields: () => [
            Wrap(
              runSpacing: 8,
              children: [
                TecnicoSearchField(
                  label: "Nome*",
                  tecnicoBloc: bloc,
                  controller: nomeController,
                  validator: validator.byField(tecnicoForm, ErrorCodeKey.nomeESobrenome.name),
                  onChanged: tecnicoForm.setNome,
                  isForListScreen: isForListScreen,
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
