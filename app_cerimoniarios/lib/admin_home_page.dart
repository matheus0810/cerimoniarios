import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar_escala_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painel do Coordenador'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Nova Escala',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CriarEscalaPage()),
              );
            },
          )
        ],
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
