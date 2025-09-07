import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_event.dart';
import 'package:ft_loc/blocs/firebase_auth_state.dart';
import 'package:ft_loc/models/sign_in_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

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
      child: Scaffold(
        appBar: AppBar(title: Text("Entrar")),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _controllerEmail,
                      decoration: InputDecoration(labelText: "Email"),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _controllerPassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Senha",
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
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_controllerEmail.text.isEmpty ||
                                  _controllerPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Por favor, preencha o email e a senha.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                FirebaseAuthBloc firebaseAuthBloc =
                                    BlocProvider.of<FirebaseAuthBloc>(context);
                                SignInModel signInModel = SignInModel(
                                  email: _controllerEmail.text,
                                  password: _controllerPassword.text,
                                );
                                firebaseAuthBloc.add(
                                  SignInUser(signInModel: signInModel),
                                );
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Entrar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
