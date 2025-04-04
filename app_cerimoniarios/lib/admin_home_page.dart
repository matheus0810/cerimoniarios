import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar_escala_page.dart';
import 'listar_escalas_page.dart';
import 'calendario_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> enviarNotificacaoTeste() async {
    final token = await pegarTokenDeTeste();
    if (token == null) return;

    await http.post(
      Uri.parse('https://servidor-notificacoes.onrender.com/enviar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'titulo': 'Notificação Teste',
        'corpo': 'Essa é uma notificação de teste.',
      }),
    );
  }

  Future<String?> pegarTokenDeTeste() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('fcm_token', isNotEqualTo: null)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['fcm_token'];
    }
    return null;
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
              title: Text('Calendário'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarioPage()));
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: enviarNotificacaoTeste,
              icon: Icon(Icons.notifications_active),
              label: Text('Notificação Teste'),
            ),
          )
        ],
      ),
    );
  }
}
