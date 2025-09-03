import 'package:ft_loc/models/current_user_model.dart';

abstract class FirebaseAuthState {}

class FirebaseAuthenticated extends FirebaseAuthState {
  CurrentUserModel currentUserModel;

  FirebaseAuthenticated({required this.currentUserModel});
}

class FirebaseUnauthenticated extends FirebaseAuthState {}

class FirebaseAuthError extends FirebaseAuthState {
  String errorMessage;

  FirebaseAuthError({required this.errorMessage});
}

class FirebaseAuthLoading extends FirebaseAuthState {}
