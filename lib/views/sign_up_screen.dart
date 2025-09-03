import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_event.dart';
import 'package:ft_loc/blocs/firebase_auth_state.dart';
import 'package:ft_loc/blocs/firebase_store_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_event.dart';
import 'package:ft_loc/models/sign_in_model.dart';
import 'package:ft_loc/models/sign_up_data_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerIdade = TextEditingController();
  final TextEditingController _controllerCurso = TextEditingController();
  final TextEditingController _controllerAno = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late Future<Map<String, dynamic>> _salasFuture;

  @override
  void initState() {
    super.initState();
    _salasFuture = loadJson();
  }

  Future<Map<String, dynamic>> loadJson() async {
    final jsonString = await rootBundle.loadString(
      "assets/sign_up_data_asset.json",
    );
    return await json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirebaseAuthBloc, FirebaseAuthState>(
      listener: (context, state) {
        if (state is FirebaseAuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is FirebaseAuthenticated) {
          setState(() {
            _isLoading = false;
          });

          FirebaseStoreBloc firebaseStoreBloc =
              BlocProvider.of<FirebaseStoreBloc>(context, listen: false);
          SignUpDataModel signUpDataModel = SignUpDataModel(
            nome: _controllerNome.text,
            idade: _controllerIdade.text,
            curso: _controllerCurso.text,
            anoDeIngresso: _controllerAno.text,
          );
          firebaseStoreBloc.add(
            InsertUserData(signUpDataModel: signUpDataModel),
          );

          Navigator.pop(context);
        } else if (state is FirebaseAuthError) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _salasFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
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

          return Scaffold(
            appBar: AppBar(
              title: Text("Sign Up Screen"),
              backgroundColor: Colors.blueGrey,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _controllerNome,
                        decoration: InputDecoration(labelText: "Nome*"),
                      ),
                      SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerIdade,
                        label: const Text("Selecione sua idade*"),
                        width: 250,
                        menuHeight: 300,
                        dropdownMenuEntries: idadeEntries,
                      ),
                      SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerCurso,
                        label: const Text("Selecione seu curso*"),
                        width: 250,
                        menuHeight: 200,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: cursosEntries,
                      ),
                      SizedBox(height: 30),
                      DropdownMenu(
                        controller: _controllerAno,
                        label: const Text("Selecione seu ano de ingresso"),
                        width: 250,
                        menuHeight: 200,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        dropdownMenuEntries: anosEntries,
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _controllerEmail,
                        decoration: InputDecoration(labelText: "Email*"),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _controllerPassword,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Senha*",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_controllerNome.text.isEmpty ||
                                    _controllerIdade.text.isEmpty ||
                                    _controllerCurso.text.isEmpty ||
                                    _controllerEmail.text.isEmpty ||
                                    _controllerPassword.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Por favor, preencha todos os campos obrigatórios (*).",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  FirebaseAuthBloc firebaseAuthBloc =
                                      BlocProvider.of<FirebaseAuthBloc>(
                                        context,
                                      );
                                  SignInModel signInModel = SignInModel(
                                    email: _controllerEmail.text,
                                    password: _controllerPassword.text,
                                  );
                                  firebaseAuthBloc.add(
                                    SignUpUser(signInModel: signInModel),
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Cadastrar"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
