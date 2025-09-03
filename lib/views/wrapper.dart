import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_state.dart';
import 'package:ft_loc/views/home_screen.dart';
import 'package:ft_loc/views/main_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirebaseAuthBloc, FirebaseAuthState>(
      builder: (context, state) {
        if (state is FirebaseAuthenticated) {
          return MainScreen();
        } else {
          return HomeScreen();
        }
      },
    );
  }
}
