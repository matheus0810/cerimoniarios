import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar_escala_page.dart';
import 'listar_escalas_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Painel do Coordenador')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),
            ListTile(
              title: Text('Ver Escalas'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ListarEscalasPage()));
              },
            ),
            ListTile(
              title: Text('Nova Escala'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CriarEscalaPage()));
              },
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(user['nome']),
                subtitle: Text(user['email']),
                trailing: Text(user['funcao']),
              );
            },
          );
        },
      ),
    );
  }
}