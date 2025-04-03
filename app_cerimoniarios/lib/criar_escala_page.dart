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

  final locais = ['São Francisco - Matriz', 'São Raphael', 'São Judas'];
  final funcoes = ['mestre', 'auxiliar', 'naveta', 'turibulo'];

  Map<String, bool> selecionados = {}; // uid => true/false
  Map<String, String> funcoesSelecionadas = {}; // uid => função

  void salvarEscala() async {
    if (dataSelecionada == null ||
        horario.isEmpty ||
        local.isEmpty ||
        selecionados.values.where((v) => v).isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final cerimoniarios = <Map<String, dynamic>>[];
    final uids = <String>[];

    for (final entry in selecionados.entries) {
      if (entry.value) {
        final uid = entry.key;
        final doc =
            await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
        final data = doc.data()!;
        cerimoniarios.add({
          'uid': uid,
          'nome': data['nome'],
          'funcao': funcoesSelecionadas[uid] ?? '',
        });
        uids.add(uid);
      }
    }

    await FirebaseFirestore.instance.collection('escalas').add({
      'data': dataSelecionada!.toIso8601String(),
      'horario': horario,
      'local': local,
      'uids': uids, // auxiliar para filtragem
      'cerimoniarios': cerimoniarios,
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
            Text('Selecione os cerimoniários:'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final users = snapshot.data!.docs;
                return Column(
                  children: users.map((doc) {
                    final user = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;
                    selecionados.putIfAbsent(uid, () => false);
                    funcoesSelecionadas.putIfAbsent(uid, () => funcoes.first);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(user['nome']),
                          subtitle: Text(user['email']),
                          value: selecionados[uid],
                          onChanged: (val) {
                            setState(() => selecionados[uid] = val ?? false);
                          },
                        ),
                        if (selecionados[uid] == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: DropdownButton<String>(
                              value: funcoesSelecionadas[uid],
                              items: funcoes
                                  .map((f) =>
                                      DropdownMenuItem(value: f, child: Text(f)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => funcoesSelecionadas[uid] = val!),
                              hint: Text('Função'),
                            ),
                          ),
                        Divider(),
                      ],
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