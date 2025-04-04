import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fcm_service.dart';

class CriarEscalaPage extends StatefulWidget {
  @override
  _CriarEscalaPageState createState() => _CriarEscalaPageState();
}

class _CriarEscalaPageState extends State<CriarEscalaPage> {
  DateTime? dataSelecionada;
  String horario = '';
  String local = 'São Francisco - Matriz';
  String busca = '';

  final locais = ['São Francisco - Matriz', 'São Raphael', 'São Judas'];
  final funcoes = ['mestre', 'auxiliar', 'naveta', 'turibulo'];

  Map<String, Map<String, dynamic>> selecionados = {}; // uid => {nome, funcao}

  void salvarEscala() async {
    if (dataSelecionada == null ||
        horario.isEmpty ||
        local.isEmpty ||
        selecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Preencha todos os campos'),
      ));
      return;
    }

    final listaFinal = selecionados.entries.map((e) {
      return {
        'uid': e.key,
        'nome': e.value['nome'],
        'funcao': e.value['funcao'],
      };
    }).toList();

    final tokens = <String>[];

    for (final uid in selecionados.keys) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final token = doc.data()?['fcm_token'];
      if (token != null) tokens.add(token);
    }

    await FirebaseFirestore.instance.collection('escalas').add({
      'data': dataSelecionada!.toIso8601String(),
      'horario': horario,
      'local': local,
      'uids': selecionados.keys.toList(),
      'cerimoniarios': listaFinal,
    });

for (final token in tokens) {
  await http.post(
    Uri.parse('https://servidor-notificacoes.onrender.com/enviar'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'token': token,
      'titulo': 'Nova Escala',
      'corpo': 'Você foi escalado para a missa em $local às $horario.',
    }),
  );
}


    Navigator.pop(context);
  }

  Widget buildSelecionados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selecionados.entries.map((entry) {
        final uid = entry.key;
        final dados = entry.value;
        return ListTile(
          title: Text(dados['nome']),
          trailing: DropdownButton<String>(
            value: dados['funcao'],
            items: funcoes
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selecionados[uid]!['funcao'] = val!;
              });
            },
          ),
          leading: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                selecionados.remove(uid);
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget buildBuscaUsuarios() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = data['nome']?.toLowerCase() ?? '';
          return busca.isNotEmpty &&
              nome.contains(busca.toLowerCase()) &&
              !selecionados.containsKey(doc.id);
        }).toList();

        return Column(
          children: results.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['nome']),
              subtitle: Text(data['email']),
              onTap: () {
                setState(() {
                  selecionados[doc.id] = {
                    'nome': data['nome'],
                    'funcao': funcoes.first,
                  };
                  busca = '';
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Escala')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              title: Text(dataSelecionada == null
                  ? 'Selecione a data'
                  : 'Data: ${dataSelecionada!.toLocal().toString().split(" ")[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (data != null) setState(() => dataSelecionada = data);
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Horário (ex: 18:00)'),
              onChanged: (val) => horario = val,
            ),
            DropdownButtonFormField<String>(
              value: local,
              items: locais.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => local = val!),
              decoration: InputDecoration(labelText: 'Local'),
            ),
            Divider(),
            TextField(
              decoration: InputDecoration(labelText: 'Buscar cerimoniário'),
              onChanged: (val) => setState(() => busca = val),
            ),
            buildBuscaUsuarios(),
            Divider(),
            Text('Escalados:', style: TextStyle(fontWeight: FontWeight.bold)),
            buildSelecionados(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarEscala,
              child: Text('Salvar Escala'),
            ),
          ],
        ),
      ),
    );
  }
}