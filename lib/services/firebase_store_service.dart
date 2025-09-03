import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_loc/models/sign_up_data_model.dart';
import 'package:ft_loc/services/firebase_auth_service.dart';

class FirebaseStoreService {
  final CollectionReference userDataCollection = FirebaseFirestore.instance
      .collection("userData");

  final FirebaseAuthService _authService;
  FirebaseStoreService({required FirebaseAuthService authService})
    : _authService = authService;

  Future<void> insertUserData(SignUpDataModel signUpDataModel) async {
    String? currentUserUid = await _authService.currentUserUidAsync;
    if (currentUserUid != null) {
      await userDataCollection.doc(currentUserUid).set(signUpDataModel.toMap());
    }
  }

  Future<void> updateUserData(SignUpDataModel signUpDataModel) async {
    String? currentUserUid = _authService.currentUserUid;
    if (currentUserUid != null) {
      await userDataCollection
          .doc(currentUserUid)
          .update(signUpDataModel.toMap());
    }
  }

  Future<SignUpDataModel?> getUserData() async {
    String? currentUserUid = _authService.currentUserUid;

    if (currentUserUid == null) {
      return null;
    }

    final DocumentSnapshot doc = await userDataCollection
        .doc(currentUserUid)
        .get();

    if (doc.exists) {
      return SignUpDataModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }
}
