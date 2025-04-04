import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';
import 'admin_home_page.dart';
import 'home_page.dart';
import 'firebase_token_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String senha = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

void verificarLogin() async {
  print('🔍 verificando login');
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final user = FirebaseAuth.instance.currentUser;
    print('👤 FirebaseAuth.currentUser: $user');

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        final dados = doc.data();
        print('📄 Dados do Firestore: $dados');

        if (dados == null || !dados.containsKey('funcao')) {
          print('⚠️ Documento do usuário sem dados ou sem função');
          return;
        }

        if (dados['funcao'] == 'coordenador') {
          print('➡️ Redirecionando para AdminHomePage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomePage()),
          );
        } else {
          print('➡️ Redirecionando para HomePage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        }
      } catch (e) {
        print('❌ Erro ao consultar Firestore: $e');
      }
    }
  });
}

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
        verificarLogin(); // Redireciona após login
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
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
