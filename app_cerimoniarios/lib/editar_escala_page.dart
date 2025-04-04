import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarEscalaPage extends StatefulWidget {
  final String escalaId;
  final Map<String, dynamic> escala;

  const EditarEscalaPage({required this.escalaId, required this.escala});

  @override
  _EditarEscalaPageState createState() => _EditarEscalaPageState();
}

class _EditarEscalaPageState extends State<EditarEscalaPage> {
  DateTime? dataSelecionada;
  String horario = '';
  String local = 'São Francisco - Matriz';

  final locais = ['São Francisco - Matriz', 'São Raphael', 'São Judas'];
  final funcoes = ['mestre', 'auxiliar', 'naveta', 'turibulo'];

  Map<String, Map<String, dynamic>> selecionados = {};

  @override
  void initState() {
    super.initState();
    final dataString = widget.escala['data'];
    dataSelecionada = DateTime.tryParse(dataString);
    horario = widget.escala['horario'] ?? '';
    local = locais.contains(widget.escala['local']) ? widget.escala['local'] : locais[0];
    for (var cerimoniario in widget.escala['cerimoniarios']) {
      selecionados[cerimoniario['uid']] = {
        'nome': cerimoniario['nome'],
        'funcao': funcoes.contains(cerimoniario['funcao']) ? cerimoniario['funcao'] : funcoes.first,
      };
    }
  }

  void salvarEdicao() async {
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

    await FirebaseFirestore.instance.collection('escalas').doc(widget.escalaId).update({
      'data': dataSelecionada!.toIso8601String(),
      'horario': horario,
      'local': local,
      'uids': selecionados.keys.toList(),
      'cerimoniarios': listaFinal,
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Escala')),
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
                  initialDate: dataSelecionada ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (data != null) setState(() => dataSelecionada = data);
              },
            ),
            TextFormField(
              initialValue: horario,
              decoration: InputDecoration(labelText: 'Horário (ex: 18:00)'),
              onChanged: (val) => horario = val,
            ),
            DropdownButtonFormField<String>(
              value: locais.contains(local) ? local : locais[0],
              items: locais.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => local = val!),
              decoration: InputDecoration(labelText: 'Local'),
            ),
            Divider(),
            Text('Escalados:', style: TextStyle(fontWeight: FontWeight.bold)),
            buildSelecionados(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarEdicao,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
