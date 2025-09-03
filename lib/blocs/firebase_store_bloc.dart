import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ft_loc/blocs/firebase_store_event.dart';
import 'package:ft_loc/blocs/firebase_store_state.dart';
import 'package:ft_loc/services/firebase_store_service.dart';

class FirebaseStoreBloc extends Bloc<FirebaseStoreEvent, FirebaseStoreState> {
  final FirebaseStoreService _storeService;

  FirebaseStoreBloc({required FirebaseStoreService storeService})
    : _storeService = storeService,
      super(StoreInitial()) {
    on<InsertUserData>((event, emit) async {
      emit(StoreLoading());
      try {
        await _storeService.insertUserData(event.signUpDataModel);
        emit(StoreSuccess());
      } catch (e) {
        emit(StoreError(errorMessage: e.toString()));
      }
    });

    on<UpdateUserData>((event, emit) async {
      emit(StoreLoading());
      try {
        await _storeService.updateUserData(event.signUpDataModel);
        emit(StoreSuccess());
      } catch (e) {
        emit(StoreError(errorMessage: e.toString()));
      }
    });

    on<FetchUserData>((event, emit) async {
      emit(StoreLoading());
      try {
        final userData = await _storeService.getUserData();
        if (userData != null) {
          emit(StoreUserDataLoaded(userData: userData));
        } else {
          emit(StoreUserDataEmpty());
        }
      } catch (e) {
        emit(StoreError(errorMessage: e.toString()));
      }
    });
  }
}
