import 'package:flutter/material.dart';

class CardServiceAgenda extends StatelessWidget {
  final String cliente;
  final String equipamento;
  final String tecnico;
  final String local;
  final String data;
  final String status;

  const CardServiceAgenda({
    Key? key,
    required this.cliente,
    required this.equipamento,
    required this.tecnico,
    required this.local,
    required this.data,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: constraints.maxWidth * 0.05),
                      child: Text(
                        cliente,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding:
                          EdgeInsets.only(left: constraints.maxWidth * 0.1),
                      child: Text(
                        equipamento,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.045,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(
                          left: constraints.maxWidth * 0.1,
                          top: constraints.maxWidth * 0.035),
                      child: Text(
                        tecnico,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding:
                          EdgeInsets.only(left: constraints.maxWidth * 0.15),
                      child: Text(
                        local,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(
                        left: constraints.maxWidth * 0.15,
                      ),
                      child: Text(
                        data,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                // Texto laranja
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: constraints.maxWidth * 0.4,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
