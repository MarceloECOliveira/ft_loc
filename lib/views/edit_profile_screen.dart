import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_event.dart';
import 'package:ft_loc/blocs/firebase_store_state.dart';
import 'package:ft_loc/models/sign_up_data_model.dart';

class EditProfileScreen extends StatefulWidget {
  final SignUpDataModel initialUserData;

  const EditProfileScreen({super.key, required this.initialUserData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _controllerNome;
  late TextEditingController _controllerIdade;
  late TextEditingController _controllerCurso;
  late TextEditingController _controllerAno;

  bool _isLoading = false;
  late Future<Map<String, dynamic>> _signUpDataFuture;

  @override
  void initState() {
    super.initState();

    _controllerNome = TextEditingController(text: widget.initialUserData.nome);
    _controllerIdade = TextEditingController(
      text: widget.initialUserData.idade,
    );
    _controllerCurso = TextEditingController(
      text: widget.initialUserData.curso,
    );
    _controllerAno = TextEditingController(
      text: widget.initialUserData.anoDeIngresso,
    );

    _signUpDataFuture = loadJson();
  }

  Future<Map<String, dynamic>> loadJson() async {
    final jsonString = await rootBundle.loadString(
      "assets/sign_up_data_asset.json",
    );
    return await json.decode(jsonString);
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerIdade.dispose();
    _controllerCurso.dispose();
    _controllerAno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirebaseStoreBloc, FirebaseStoreState>(
      listener: (context, state) {
        if (state is StoreLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is StoreSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context, true);
        } else if (state is StoreError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao atualizar: ${state.errorMessage}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edição de Perfil"),
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: _signUpDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData == false) {
                return const Center(
                  child: Text("Erro ao carregar dados do formulário."),
                );
              }
          
              final data = snapshot.data!;
              final List<DropdownMenuEntry<String>> idadeEntries =
                  (data["idades"] as List<dynamic>)
                      .map(
                        (idade) => DropdownMenuEntry(
                          value: idade.toString(),
                          label: idade.toString(),
                        ),
                      )
                      .toList();
              final List<DropdownMenuEntry<String>> cursosEntries =
                  (data["cursos"] as List<dynamic>)
                      .map(
                        (curso) => DropdownMenuEntry(
                          value: curso.toString(),
                          label: curso.toString(),
                        ),
                      )
                      .toList();
              final List<DropdownMenuEntry<String>> anosEntries =
                  (data["anos_ingresso"] as List<dynamic>)
                      .map(
                        (ano) => DropdownMenuEntry(
                          value: ano.toString(),
                          label: ano.toString(),
                        ),
                      )
                      .toList();
          
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _controllerNome,
                        decoration: const InputDecoration(labelText: "Nome*"),
                      ),
                      const SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerIdade,
                        label: const Text("Selecione sua idade*"),
                        width: 250,
                        menuHeight: 200,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: idadeEntries,
                        onSelected: (String? value) {
                          if (value != null) {
                            _controllerIdade.text = value;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerCurso,
                        label: const Text("Selecione seu curso*"),
                        width: 250,
                        menuHeight: 200,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: cursosEntries,
                        onSelected: (String? value) {
                          if (value != null) {
                            _controllerCurso.text = value;
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerAno,
                        label: const Text("Selecione seu ano de ingresso"),
                        width: 250,
                        menuHeight: 200,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: anosEntries,
                        onSelected: (String? value) {
                          if (value != null) {
                            _controllerAno.text = value;
                          }
                        },
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_controllerNome.text.isNotEmpty &&
                                    _controllerIdade.text.isNotEmpty &&
                                    _controllerCurso.text.isNotEmpty) {
                                  final updatedModel = SignUpDataModel(
                                    nome: _controllerNome.text,
                                    idade: _controllerIdade.text,
                                    curso: _controllerCurso.text,
                                    anoDeIngresso: _controllerAno.text,
                                  );
          
                                  BlocProvider.of<FirebaseStoreBloc>(context).add(
                                    UpdateUserData(signUpDataModel: updatedModel),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Por favor, preencha todos os campos obrigatórios (*).",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Salvar Alterações"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
