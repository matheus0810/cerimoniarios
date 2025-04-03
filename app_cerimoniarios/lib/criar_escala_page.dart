import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CriarEscalaPage extends StatefulWidget {
  @override
  _CriarEscalaPageState createState() => _CriarEscalaPageState();
}

class _CriarEscalaPageState extends State<CriarEscalaPage> {
  DateTime? dataSelecionada;
  String horario = '';
  String local = 'São Francisco - Matriz';
  List<Map<String, dynamic>> listaSelecionada = [];

  final locais = ['São Francisco - Matriz', 'São Raphael', 'São Judas'];
  final funcoes = ['mestre', 'auxiliar', 'naveta', 'turibulo'];

  void salvarEscala() async {
    if (dataSelecionada == null || horario.isEmpty || local.isEmpty || listaSelecionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    await FirebaseFirestore.instance.collection('escalas').add({
      'data': dataSelecionada!.toIso8601String(),
      'horario': horario,
      'local': local,
      'cerimoniarios': listaSelecionada,
    });

    Navigator.pop(context);
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
            SizedBox(height: 20),
            Text('Cerimoniários escalados:'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final users = snapshot.data!.docs;
                return Column(
                  children: users.map((doc) {
                    final user = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(user['nome']),
                      subtitle: Text(user['email']),
                      trailing: DropdownButton<String>(
                        hint: Text('Função'),
                        value: listaSelecionada.firstWhere((e) => e['uid'] == doc.id, orElse: () => {})['funcao'],
                        items: funcoes.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (funcao) {
                          setState(() {
                            listaSelecionada.removeWhere((e) => e['uid'] == doc.id);
                            listaSelecionada.add({
                              'uid': doc.id,
                              'nome': user['nome'],
                              'funcao': funcao,
                            });
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarEscala,
              child: Text('Salvar Escala'),
            )
          ],
        ),
      ),
    );
  }
}