import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String senha = '';
  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    !val!.contains('@') ? 'Informe um e-mail válido' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (val) => senha = val,
                validator: (val) =>
                    val!.length < 6 ? 'Senha muito curta' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: Text('Entrar')),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => RegisterPage()));
                },
                child: Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
