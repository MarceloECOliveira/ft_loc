import 'package:ft_loc/models/sign_up_data_model.dart';

abstract class FirebaseStoreEvent {}

class InsertUserData extends FirebaseStoreEvent {
  SignUpDataModel signUpDataModel;

  InsertUserData({required this.signUpDataModel});
}

class UpdateUserData extends FirebaseStoreEvent {
  SignUpDataModel signUpDataModel;

  UpdateUserData({required this.signUpDataModel});
}

class FetchUserData extends FirebaseStoreEvent {}
