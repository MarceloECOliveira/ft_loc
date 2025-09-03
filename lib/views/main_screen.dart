import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_event.dart';
import 'package:ft_loc/views/map_screen.dart';
import 'package:ft_loc/views/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controllerSalaInicio = TextEditingController();
  final TextEditingController _controllerSalaDestino = TextEditingController();

  Map<String, dynamic>? _salaInicioSelecionada;
  Map<String, dynamic>? _salaDestinoSelecionada;

  late Future<List<Map<String, dynamic>>> _salasFuture;

  @override
  void initState() {
    super.initState();
    _salasFuture = loadJson();
  }

  Future<List<Map<String, dynamic>>> loadJson() async {
    final jsonString = await rootBundle.loadString("assets/salas_asset.json");

    final List<dynamic> decoded = json.decode(jsonString);

    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _salasFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const Center(child: CircularProgressIndicator());
        }
        final salas = snapshot.data!;

        final inicioEntries = salas
            .map(
              (sala) => DropdownMenuEntry<Map<String, dynamic>>(
                value: sala,
                label: sala["nome"],
              ),
            )
            .toList();

        final destinoEntries = salas
            .map(
              (sala) => DropdownMenuEntry<Map<String, dynamic>>(
                value: sala,
                label: sala["nome"],
              ),
            )
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("Main Screen"),
            backgroundColor: Colors.blueGrey,
            leading: FloatingActionButton(
              child: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuthBloc firebaseAuthBloc =
                    BlocProvider.of<FirebaseAuthBloc>(context);
                firebaseAuthBloc.add(SignOutUser());
              },
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownMenu(
                    controller: _controllerSalaInicio,
                    label: const Text("Selecione a sala de início"),
                    width: 250,
                    dropdownMenuEntries: inicioEntries,
                    onSelected: (Map<String, dynamic>? value) {
                      setState(() {
                        _salaInicioSelecionada = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  DropdownMenu(
                    controller: _controllerSalaDestino,
                    label: const Text("Selecione a sala de destino"),
                    width: 250,
                    dropdownMenuEntries: destinoEntries,
                    onSelected: (Map<String, dynamic>? value) {
                      setState(() {
                        _salaDestinoSelecionada = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_salaInicioSelecionada != null &&
                          _salaDestinoSelecionada != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              salaInicio: _salaInicioSelecionada!,
                              salaDestino: _salaDestinoSelecionada!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Por favor, selecione ambas as salas",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Traçar rota"),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
