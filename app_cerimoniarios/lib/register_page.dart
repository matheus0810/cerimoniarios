import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String nome = '';
  String email = '';
  String senha = '';
  String confirmar = '';
  String funcao = 'cerimoniario'; // valor padrão
  final _formKey = GlobalKey<FormState>();
  final List<String> funcoes = ['cerimoniario', 'coordenador']; // opções

  void registrar() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(cred.user!.uid)
            .set({
              'nome': nome,
              'email': email,
              'funcao': funcao, // salva como "coordenador" ou "cerimoniario"
            });
        Navigator.pop(context); // volta pro login
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar conta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome completo'),
                onChanged: (val) => nome = val,
                validator: (val) => val!.isEmpty ? 'Informe seu nome' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                onChanged: (val) => email = val,
                validator:
                    (val) => !val!.contains('@') ? 'E-mail inválido' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (val) => senha = val,
                validator:
                    (val) => val!.length < 6 ? 'Senha muito curta' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirmar senha'),
                obscureText: true,
                onChanged: (val) => confirmar = val,
                validator:
                    (val) => val != senha ? 'Senhas não coincidem' : null,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Função'),
                value: funcao,
                items:
                    funcoes
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                onChanged: (val) => setState(() => funcao = val.toString()),
              ),

              SizedBox(height: 20),
              ElevatedButton(onPressed: registrar, child: Text('Cadastrar')),
            ],
          ),
        ),
      ),
    );
  }
}
