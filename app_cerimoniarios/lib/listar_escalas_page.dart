import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ListarEscalasPage extends StatefulWidget {
  const ListarEscalasPage({super.key});

  @override
  State<ListarEscalasPage> createState() => _ListarEscalasPageState();
}

class _ListarEscalasPageState extends State<ListarEscalasPage> {
  String? funcaoUsuario;
  String? uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid;
    FirebaseFirestore.instance.collection('usuarios').doc(uid).get().then((doc) {
      setState(() {
        funcaoUsuario = doc.data()?['funcao'];
      });
    });
  }

  String formatarData(String dataIso) {
    final data = DateTime.parse(dataIso);
    final formatter = DateFormat('EEEE - dd/MM/yyyy', 'pt_BR');
    return formatter.format(data);
  }

  @override
  Widget build(BuildContext context) {
    if (funcaoUsuario == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final escalasStream = funcaoUsuario == 'coordenador'
        ? FirebaseFirestore.instance.collection('escalas').orderBy('data').snapshots()
        : FirebaseFirestore.instance
            .collection('escalas')
            .where('cerimoniarios', arrayContainsAny: [{'uid': uid}])
            .orderBy('data')
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text('Escalas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: escalasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final escalas = snapshot.data!.docs;

          if (escalas.isEmpty) {
            return Center(child: Text('Nenhuma escala encontrada.'));
          }

          return ListView.builder(
            itemCount: escalas.length,
            itemBuilder: (context, i) {
              final doc = escalas[i].data() as Map<String, dynamic>;
              final data = formatarData(doc['data']);
              final horario = doc['horario'];
              final local = doc['local'];
              final lista = doc['cerimoniarios'] as List<dynamic>;

              return Card(
                margin: EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$data às $horario — $local',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(),
                      ...lista.map((c) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(c['nome']),
                            subtitle: Text('Função: ${c['funcao']}'),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}