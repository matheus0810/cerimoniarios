import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'admin_home_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_token_handler.dart';
import 'firebase_messaging_setup.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseMessagingSetup.inicializar(); // <- chamada adicionada
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await initializeDateFormatting('pt_BR', null); // <- adicione isso aqui
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
              future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return CircularProgressIndicator();
                final dados = userSnap.data!.data() as Map<String, dynamic>;
                FirebaseTokenHandler.salvarTokenFCM();
                return dados['funcao'] == 'coordenador'
                    ? AdminHomePage()
                    : HomePage();
              },
            );
          }
          return LoginPage();
        },
      ),
    );
  }
}