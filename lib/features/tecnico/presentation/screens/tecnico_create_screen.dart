import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_filter.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico_form.dart';
import 'package:serv_oeste/features/tecnico/presentation/bloc/tecnico_bloc.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';
import 'package:serv_oeste/features/tecnico/presentation/widgets/tecnico_form_widget.dart';
import 'package:serv_oeste/shared/services/specialty_cache.dart';

class TecnicoCreateScreen extends StatefulWidget {
  const TecnicoCreateScreen({super.key});

  @override
  State<TecnicoCreateScreen> createState() => _TecnicoCreateScreenState();
}

class _TecnicoCreateScreenState extends State<TecnicoCreateScreen> {
  final TecnicoForm _tecnicoForm = TecnicoForm();
  Map<String, bool> _checkersMap = {};
  Map<String, int> _conhecimentoIdsByLabel = {};
  bool _catalogReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSpecialties());
  }

  Future<void> _ensureSpecialties() async {
    final SpecialtyCache cache = context.read<SpecialtyCache>();
    if (!cache.hasData) {
      await cache.refresh();
    }
    if (!mounted) return;
    setState(() {
      _conhecimentoIdsByLabel = Map<String, int>.from(cache.activeIdByConhecimento);
      _checkersMap = {
        for (final String label in cache.activeConhecimentosOrderedWithOutros()) label: false,
      };
      _catalogReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TecnicoBloc bloc = context.read<TecnicoBloc>();

    if (!_catalogReady) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando especialidades...'),
            ],
          ),
        ),
      );
    }

    if (_checkersMap.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Não foi possível carregar especialidades.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _catalogReady = false);
                  _ensureSpecialties();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return TecnicoFormWidget(
      title: "Adicionar Técnico",
      submitText: "Adicionar Técnico",
      bloc: bloc,
      tecnicoForm: _tecnicoForm,
      successMessage: "Técnico registrado com sucesso! (Caso ele não esteja aparecendo, recarregue a página)",
      checkersMap: _checkersMap,
      conhecimentoIdsByLabel: _conhecimentoIdsByLabel,
      isForListScreen: false,
      situationMap: {},
      onSubmit: () {
        final List<String> nomes = _tecnicoForm.nome.value.split(" ");
        final String nome = nomes.first;
        final String sobrenome = nomes.sublist(1).join(" ").trim();

        _tecnicoForm.setNome(nome);

        bloc.add(
          TecnicoRegisterEvent(
            tecnico: Tecnico.fromForm(_tecnicoForm),
            sobrenome: sobrenome,
          ),
        );

        _tecnicoForm.setNome("$nome $sobrenome");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(TecnicoSearchEvent(filter: const TecnicoFilter()));
        });
      },
    );
  }
}
