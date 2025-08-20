import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serv_oeste/src/logic/tecnico/tecnico_bloc.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico.dart';
import 'package:serv_oeste/src/models/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/screens/tecnico/tecnico_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

class UpdateTecnico extends StatefulWidget {
  final int id;

  const UpdateTecnico({
    super.key,
    required this.id,
  });

  @override
  State<UpdateTecnico> createState() => _UpdateTecnicoState();
}

class _UpdateTecnicoState extends State<UpdateTecnico> {
  late final TecnicoBloc bloc;
  final TecnicoForm form = TecnicoForm();
  final ValueNotifier<String> dropDownSituacaoValue =
      ValueNotifier<String>(Constants.situationTecnicoList.first);
  final TextEditingController nomeController = TextEditingController();
  final Map<String, String> situationMap = {
    'ATIVO': 'Ativo',
    'LICENCA': 'Licença',
    'DESATIVADO': 'Desativado',
  };
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

  void _fillForm(Tecnico tecnico) {
    form.setId(widget.id);
    form.setNome("${tecnico.nome} ${tecnico.sobrenome}");
    form.setTelefoneFixo(tecnico.telefoneFixo!.isEmpty
        ? ""
        : Formatters.applyTelefoneMask(tecnico.telefoneFixo!));
    form.setTelefoneCelular(tecnico.telefoneCelular!.isEmpty
        ? ""
        : Formatters.applyCelularMask(tecnico.telefoneCelular!));

    nomeController.text = form.nome.value;

    final String tecnicoSituacao = tecnico.situacao ?? '';
    final String mappedSituacao =
        situationMap[tecnicoSituacao] ?? 'Situação...';

    dropDownSituacaoValue.value = mappedSituacao;
    form.setSituacao(mappedSituacao);

    if (tecnico.especialidades != null) {
      for (Especialidade especialidade in tecnico.especialidades!) {
        if (checkersMap.keys.contains(especialidade.conhecimento)) {
          checkersMap[especialidade.conhecimento] = true;
          form.addConhecimentos(especialidade.id);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<TecnicoBloc>();
    bloc.add(TecnicoSearchOneEvent(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TecnicoBloc, TecnicoState>(
      listenWhen: (previous, current) =>
          current is TecnicoUpdateSuccessState ||
          current is TecnicoSearchOneSuccessState,
      listener: (context, state) {
        if (state is TecnicoUpdateSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is TecnicoSearchOneSuccessState) {
          _fillForm(state.tecnico);
        }
      },
      child: BlocBuilder<TecnicoBloc, TecnicoState>(
        bloc: bloc,
        buildWhen: (previous, current) =>
            current is TecnicoSearchOneSuccessState ||
            current is TecnicoSearchOneLoadingState,
        builder: (context, state) {
          return TecnicoFormPage(
            isSkeleton: state is TecnicoSearchOneLoadingState,
            title: "Consultar/Atualizar Técnico",
            submitText: "Atualizar Técnico",
            bloc: bloc,
            tecnicoForm: form,
            nomeController: nomeController,
            isUpdate: true,
            successMessage:
                'Técnico atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)',
            checkersMap: checkersMap,
            situationMap: situationMap,
            onSubmit: () {
              final List<String> nomes = form.nome.value.split(" ");
              final String nome = nomes.first;
              final String sobrenome = nomes.sublist(1).join(" ").trim();

              form.setNome(nome);

              bloc.add(TecnicoUpdateEvent(
                  tecnico: Tecnico.fromForm(form), sobrenome: sobrenome));

              form.setNome("$nome $sobrenome");
            },
          );
        },
      ),
    );
  }
}
