import 'package:ft_loc/models/current_user_model.dart';
import 'package:ft_loc/models/sign_in_model.dart';

abstract class FirebaseAuthEvent {}

class SignInUser extends FirebaseAuthEvent {
  SignInModel signInModel;

  SignInUser({required this.signInModel});
}

class SignUpUser extends FirebaseAuthEvent {
  SignInModel signInModel;

  SignUpUser({required this.signInModel});
}

class SignOutUser extends FirebaseAuthEvent {}

class SignInAnonymously extends FirebaseAuthEvent {}

class ListenAuthServer extends FirebaseAuthEvent {
  final CurrentUserModel? currentUserModel;

  ListenAuthServer(this.currentUserModel);
}
