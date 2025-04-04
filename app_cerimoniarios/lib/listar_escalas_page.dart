import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_escala_page.dart';

class ListarEscalasPage extends StatelessWidget {
  String formatarData(String iso) {
    final data = DateTime.parse(iso);
    final semana = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return '${semana[data.weekday % 7]}, ${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escalas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('escalas')
            .orderBy('data')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView(
            children: docs.map((doc) {
              final escala = doc.data() as Map<String, dynamic>;
              final data = escala['data'] ?? '';
              final local = escala['local'] ?? '';
              final horario = escala['horario'] ?? '';
              final cerimonarios = List<Map<String, dynamic>>.from(escala['cerimoniarios'] ?? []);

              return Card(
                child: ExpansionTile(
                  title: Text('${formatarData(data)} - $horario'),
                  subtitle: Text(local),
                  trailing: Icon(Icons.edit),
                  children: [
                    ...cerimonarios.map((c) => ListTile(
                          title: Text(c['nome'] ?? ''),
                          subtitle: Text('Função: ${c['funcao'] ?? ''}'),
                        )),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarEscalaPage(
                              escalaId: doc.id,
                              escala: escala,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Editar escala'),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
