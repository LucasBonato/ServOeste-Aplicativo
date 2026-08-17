import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_filter.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_form.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_form_widget.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';
import 'package:serv_oeste/shared/services/specialty_cache.dart';
import 'package:serv_oeste/shared/utils/formatters/formatters.dart';

class TecnicoUpdateScreen extends StatefulWidget {
  final int id;

  const TecnicoUpdateScreen({
    super.key,
    required this.id,
  });

  @override
  State<TecnicoUpdateScreen> createState() => _TecnicoUpdateScreenState();
}

class _TecnicoUpdateScreenState extends State<TecnicoUpdateScreen> {
  late final TecnicoBloc bloc;
  final TecnicoForm form = TecnicoForm();
  final TextEditingController nomeController = TextEditingController();
  final Map<String, String> situationMap = {
    'ATIVO': 'Ativo',
    'LICENCA': 'Licença',
    'DESATIVADO': 'Desativado',
  };
  Map<String, bool> checkersMap = {};
  Map<String, int> conhecimentoIdsByLabel = {};
  Tecnico? _loadedTecnico;

  void _applyTecnico(Tecnico tecnico) {
    final SpecialtyCache cache = context.read<SpecialtyCache>();
    final Map<String, int> ids = Map<String, int>.from(cache.activeIdByConhecimento);
    final Map<String, bool> linked = <String, bool>{
      for (final String label in cache.activeConhecimentosOrderedWithOutros()) label: false,
    };

    form.setConhecimentos([]);
    form.setId(widget.id);
    form.setNome("${tecnico.nome} ${tecnico.sobrenome}");

    if (tecnico.telefoneFixo != null && tecnico.telefoneFixo!.isNotEmpty) {
      form.setTelefoneFixo(Formatters.applyPhoneMask(tecnico.telefoneFixo!));
    } else {
      form.setTelefoneFixo("");
    }

    if (tecnico.telefoneCelular != null && tecnico.telefoneCelular!.isNotEmpty) {
      form.setTelefoneCelular(Formatters.applyCellPhoneMask(tecnico.telefoneCelular!));
    } else {
      form.setTelefoneCelular("");
    }

    nomeController.text = form.nome.value;

    final String tecnicoSituacao = tecnico.situacao ?? '';
    final String mappedSituacao = situationMap[tecnicoSituacao] ?? 'Situação...';

    form.setSituacao(mappedSituacao);

    if (tecnico.especialidades != null) {
      for (Especialidade especialidade in tecnico.especialidades!) {
        ids[especialidade.conhecimento] = especialidade.id;
        linked.putIfAbsent(especialidade.conhecimento, () => false);
        linked[especialidade.conhecimento] = true;
        form.addConhecimentos(especialidade.id);
      }
    }

    conhecimentoIdsByLabel = ids;
    checkersMap = linked;
  }

  Future<void> _ensureCatalog() async {
    final SpecialtyCache cache = context.read<SpecialtyCache>();
    if (!cache.hasData) {
      await cache.refresh();
    }
    if (!mounted) return;
    if (_loadedTecnico != null) {
      setState(() => _applyTecnico(_loadedTecnico!));
    }
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<TecnicoBloc>();
    bloc.add(TecnicoSearchOneEvent(id: widget.id));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCatalog());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TecnicoBloc, TecnicoState>(
      listenWhen: (previous, current) => current is TecnicoUpdateSuccessState || current is TecnicoSearchOneSuccessState,
      listener: (context, state) {
        if (state is TecnicoUpdateSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is TecnicoSearchOneSuccessState) {
          _loadedTecnico = state.tecnico;
          setState(() => _applyTecnico(state.tecnico));
        }
      },
      child: BlocBuilder<TecnicoBloc, TecnicoState>(
        bloc: bloc,
        buildWhen: (previous, current) => current is TecnicoSearchOneSuccessState || current is TecnicoSearchOneLoadingState,
        builder: (context, state) {
          return TecnicoFormWidget(
            isSkeleton: state is TecnicoSearchOneLoadingState,
            title: "Consultar/Atualizar Técnico",
            submitText: "Atualizar Técnico",
            bloc: bloc,
            tecnicoForm: form,
            nomeController: nomeController,
            isUpdate: true,
            successMessage: "Técnico atualizado com sucesso! (Caso ele não esteja atualizado, recarregue a página)",
            checkersMap: checkersMap,
            conhecimentoIdsByLabel: conhecimentoIdsByLabel,
            situationMap: situationMap,
            isForListScreen: false,
            onSubmit: () {
              final List<String> nomes = form.nome.value.split(" ");
              final String nome = nomes.first;
              final String sobrenome = nomes.sublist(1).join(" ").trim();

              form.setNome(nome);

              bloc.add(TecnicoUpdateEvent(tecnico: Tecnico.fromForm(form), sobrenome: sobrenome));

              form.setNome("$nome $sobrenome");

              WidgetsBinding.instance.addPostFrameCallback((_) {
                bloc.add(TecnicoSearchEvent(filter: const TecnicoFilter()));
              });
            },
          );
        },
      ),
    );
  }
}
