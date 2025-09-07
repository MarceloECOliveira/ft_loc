import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_event.dart';
import 'package:ft_loc/views/sign_in_screen.dart';
import 'package:ft_loc/views/sign_up_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  textWidthBasis: TextWidthBasis.parent,
                  "Este é o FT Loc um aplicativo desenvolvido com o intuito de facilitar a navegação na Faculdade de Tecnologia da Unicamp",
                ),
                SizedBox(height: 120),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  child: Text("Entrar"),
                ),
                SizedBox(height: 5),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text("Cadastre-se"),
                ),
                SizedBox(height: 80),
                TextButton(
                  onPressed: () {
                    _showAnonymousSignInDialog(context);
                  },
                  child: Text("Entrar como convidado"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnonymousSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Acesso como Convidado"),
          content: const Text(
            "Com um cadastro, o aplicativo pode oferecer uma experiência mais personalizada. Deseja continuar como convidado?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Continuar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                BlocProvider.of<FirebaseAuthBloc>(
                  context,
                ).add(SignInAnonymously());
              },
            ),
          ],
        );
      },
    );
  }
}
