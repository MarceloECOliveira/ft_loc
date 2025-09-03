import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_auth_event.dart';
import 'package:ft_loc/blocs/firebase_auth_state.dart';
import 'package:ft_loc/models/current_user_model.dart';
import 'package:ft_loc/services/firebase_auth_service.dart';

class FirebaseAuthBloc extends Bloc<FirebaseAuthEvent, FirebaseAuthState> {
  // 1. Declare uma variável final para o serviço
  final FirebaseAuthService _authService;

  // 2. Receba o serviço pelo construtor
  FirebaseAuthBloc({required FirebaseAuthService authService})
    : _authService = authService, // 3. Inicialize a variável
      super(FirebaseUnauthenticated()) {
    // Ouça a stream do serviço injetado
    _authService.firebaseAuthStream.listen((
      CurrentUserModel? currentUserModel,
    ) {
      add(ListenAuthServer(currentUserModel));
    });

    on<ListenAuthServer>((event, emit) {
      if (event.currentUserModel == null) {
        emit(FirebaseUnauthenticated());
      } else {
        emit(FirebaseAuthenticated(currentUserModel: event.currentUserModel!));
      }
    });

    on<SignInUser>((event, emit) async {
      emit(FirebaseAuthLoading());
      try {
        await _authService.signInWithEmailAndPassword(
          email: event.signInModel.email,
          password: event.signInModel.password,
        );
      } catch (e) {
        emit(FirebaseAuthError(errorMessage: e.toString()));
      }
    });

    on<SignUpUser>((event, emit) async {
      emit(FirebaseAuthLoading());
      try {
        await _authService.createUserWithEmailAndPassword(
          email: event.signInModel.email,
          password: event.signInModel.password,
        );
      } catch (e) {
        emit(FirebaseAuthError(errorMessage: e.toString()));
      }
    });

    on<SignOutUser>((event, emit) {
      _authService.signOut();
    });

    on<SignInAnonymously>((event, emit) async {
      emit(FirebaseAuthLoading());
      try {
        await _authService.signInAnonymously();
      } catch (e) {
        emit(FirebaseAuthError(errorMessage: e.toString()));
      }
    });
  }
}
