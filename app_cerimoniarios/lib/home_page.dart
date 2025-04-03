import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listar_escalas_page.dart';

class HomePage extends StatelessWidget {
  Future<String> buscarNomeUsuario() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.data()?['nome'] ?? 'Sem nome';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ), 
          IconButton(
  icon: Icon(Icons.event_note),
  tooltip: 'Ver Escalas',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListarEscalasPage()),
    );
  },
),

        ],
      ),
      body: FutureBuilder<String>(
        future: buscarNomeUsuario(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Text('Bem-vindo, ${snapshot.data}!',
                style: TextStyle(fontSize: 22)),
          );
        },
        
      ),
    );
  }
}
