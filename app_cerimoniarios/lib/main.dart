import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'admin_home_page.dart'; // nova tela do coordenador

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cerimoniários',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            final uid = snapshot.data!.uid;
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final dados = userSnap.data!.data() as Map<String, dynamic>;
                final funcao = dados['funcao'];

                if (funcao == 'coordenador') {
                  return AdminHomePage();
                } else {
                  return HomePage();
                }
              },
            );
          }

          return LoginPage();
        },
      ),
    );
  }
}
