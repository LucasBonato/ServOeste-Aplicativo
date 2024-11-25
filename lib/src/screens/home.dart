import 'package:flutter/material.dart';
import 'package:serv_oeste/src/components/grid_view.dart';
import 'package:serv_oeste/src/components/card_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<dynamic> serviceDayList = [
    {
      'id': 1,
      'cliente': "Jefferson Oliveira",
      'equipamento': "Geladeira",
      'marca': "Consul",
      'tecnico': "Lucas Adriano",
      'local': "Osasco",
      'data': "11/11/2024 - Tarde",
      'status': "Aguardando Orçamento"
    },
    {
      'id': 2,
      'cliente': "Carlos Silva",
      'equipamento': "Ar Condicionado",
      'marca': "Samsung",
      'tecnico': "João",
      'local': "Osasco",
      'data': "12/11/2024 - Manhã",
      'status': "Orçamento Aprovado"
    },
    {
      'id': 3,
      'cliente': "Maria Souza",
      'equipamento': "Micro-ondas",
      'marca': "LG",
      'tecnico': "Pedro",
      'local': "Carapicuíba",
      'data': "12/11/2024 - Tarde",
      'status': "Aguardando Agendamento"
    },
    {
      'id': 4,
      'cliente': "Luciana Mendes",
      'equipamento': "Máquina de Lavar",
      'marca': "Brastemp",
      'tecnico': "Marcos",
      'local': "Osasco",
      'data': "13/11/2024 - Manhã",
      'status': "Aguardando Aprovação do Cliente"
    },
    {
      'id': 5,
      'cliente': "Gustavo Lima",
      'equipamento': "Secadora de Roupas",
      'marca': "Electrolux",
      'tecnico': "Ana Paula",
      'local': "Osasco",
      'data': "13/11/2024 - Tarde",
      'status': "Aguardando Orçamento"
    },
    {
      'id': 6,
      'cliente': "Fabiana Rocha",
      'equipamento': "Geladeira",
      'marca': "Eletrolux",
      'tecnico': "João",
      'local': "Osasco",
      'data': "14/11/2024 - Manhã",
      'status': "Orçamento Aprovado"
    },
    {
      'id': 7,
      'cliente': "José Almeida",
      'equipamento': "Fogão",
      'marca': "Atlas",
      'tecnico': "Carlos",
      'local': "Carapicuíba",
      'data': "14/11/2024 - Tarde",
      'status': "Aguardando Atendimento"
    },
    {
      'id': 8,
      'cliente': "Patricia Lima",
      'equipamento': "Micro-ondas",
      'marca': "Panasonic",
      'tecnico': "Luana",
      'local': "Carapicuíba",
      'data': "15/11/2024 - Manhã",
      'status': "Aguardando Cliente Retirar"
    },
    {
      'id': 9,
      'cliente': "Roberto Oliveira",
      'equipamento': "Ar Condicionado",
      'marca': "Midea",
      'tecnico': "Bruno",
      'local': "Carapicuíba",
      'data': "15/11/2024 - Tarde",
      'status': "Resolvido"
    },
    {
      'id': 10,
      'cliente': "Ana Costa",
      'equipamento': "Máquina de Lavar",
      'marca': "Samsung",
      'tecnico': "Ricardo",
      'local': "Carapicuíba",
      'data': "16/11/2024 - Manhã",
      'status': "Aguardando Orçamento"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/heroImage3.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Text(
              "Agenda do Dia",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width.clamp(18.0, 26.0),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridListView(
            dataList: serviceDayList,
            buildCard: _buildAgendaCard,
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(dynamic data) {
    return CardService(
      cliente: data['cliente'],
      equipamento: data['equipamento'],
      marca: data['marca'],
      tecnico: data['tecnico'],
      local: data['local'],
      data: data['data'],
      status: data['status'],
    );
  }
}
