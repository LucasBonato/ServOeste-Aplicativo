import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_form.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_form_widget.dart';

class TecnicoCreateScreen extends StatelessWidget {
  const TecnicoCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TecnicoBloc bloc = context.read<TecnicoBloc>();
    final TecnicoForm tecnicoForm = TecnicoForm();
    final Map<String, bool> checkersMap = {
      "Adega": false,
      "Air Fryer": false,
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

    return TecnicoFormWidget(
      title: "Adicionar Técnico",
      submitText: "Adicionar Técnico",
      bloc: bloc,
      tecnicoForm: tecnicoForm,
      successMessage: "Técnico registrado com sucesso! (Caso ele não esteja aparecendo, recarregue a página)",
      checkersMap: checkersMap,
      isForListScreen: false,
      situationMap: {},
      onSubmit: () {
        final List<String> nomes = tecnicoForm.nome.value.split(" ");
        final String nome = nomes.first;
        final String sobrenome = nomes.sublist(1).join(" ").trim();

        tecnicoForm.setNome(nome);

        bloc.add(
          TecnicoRegisterEvent(
            tecnico: Tecnico.fromForm(tecnicoForm),
            sobrenome: sobrenome,
          ),
        );

        tecnicoForm.setNome("$nome $sobrenome");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(TecnicoSearchMenuEvent());
        });
      },
    );
  }
}
