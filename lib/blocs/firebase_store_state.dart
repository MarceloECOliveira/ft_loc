import 'package:ft_loc/models/sign_up_data_model.dart';

abstract class FirebaseStoreState {}

class StoreInitial extends FirebaseStoreState {}

class StoreLoading extends FirebaseStoreState {}

class StoreSuccess extends FirebaseStoreState {}

class StoreUserDataLoaded extends FirebaseStoreState {
  final SignUpDataModel userData;

  StoreUserDataLoaded({required this.userData});
}

class StoreUserDataEmpty extends FirebaseStoreState {}

class StoreError extends FirebaseStoreState {
  final String errorMessage;

  StoreError({required this.errorMessage});
}
