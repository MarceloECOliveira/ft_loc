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
      appBar: AppBar(title: Text("FT Loc")),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon.png', // O mesmo caminho do pubspec.yaml
                  width: 150, // Ajuste o tamanho como desejar
                  height: 150,
                ),
                const SizedBox(
                  height: 40,
                ), // Espaçamento entre o ícone e o texto

                const Text(
                  "Este é o FT Loc, um aplicativo desenvolvido com o intuito de facilitar a navegação na Faculdade de Tecnologia da Unicamp",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60), // Espaçamento ajustado
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text("Entrar"),
                ),
                const SizedBox(height: 5),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text("Cadastre-se"),
                ),
                const SizedBox(height: 40), // Espaçamento ajustado
                TextButton(
                  onPressed: () {
                    _showAnonymousSignInDialog(context);
                  },
                  child: const Text("Entrar como convidado"),
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
