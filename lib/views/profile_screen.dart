import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_event.dart';
import 'package:ft_loc/blocs/firebase_store_state.dart';
import 'package:ft_loc/views/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FirebaseStoreBloc>(context).add(FetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: SafeArea(
        child: BlocBuilder<FirebaseStoreBloc, FirebaseStoreState>(
          builder: (context, state) {
            if (state is StoreLoading || state is StoreInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StoreUserDataLoaded) {
              final userData = state.userData;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text("Nome"),
                        subtitle: Text(userData.nome),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.cake_outlined),
                        title: const Text("Idade"),
                        subtitle: Text(userData.idade),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: const Text("Curso"),
                        subtitle: Text(userData.curso),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text("Ano de Ingresso"),
                        subtitle: Text(userData.anoDeIngresso),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(initialUserData: userData),
                            ),
                          );

                          if (result == true && context.mounted) {
                            BlocProvider.of<FirebaseStoreBloc>(
                              context,
                            ).add(FetchUserData());
                          }
                        },
                        child: const Text("Editar informações"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is StoreUserDataEmpty) {
              return const Center(
                child: Text(
                  "Nenhum perfil encontrado.\nUsuários convidados não possuem dados de perfil.",
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (state is StoreError) {
              return Center(
                child: Text("Ocorreu um erro: ${state.errorMessage}"),
              );
            }

            return const Center(child: Text("Nenhum dado para exibir."));
          },
        ),
      ),
    );
  }
}
