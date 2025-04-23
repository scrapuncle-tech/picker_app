import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/common/custom_snackbar.component.dart';
import '../main.dart';
import '../models/auth_process_state.model.dart';
import '../models/auth_state.model.dart';
import '../services/background/sync.service.dart';
import '../services/firebase/auth.service.dart';
import '../services/objectbox/auth.service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthFunctions _authFunctions = AuthFunctions();
  final OBAuthService _obAuthService = OBAuthService(objectbox: objectbox!);
  AuthNotifier() : super(AuthState()) {
    // Listen to Firebase auth state changes
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _obAuthService.getPicker().listen((picker) {
      if (picker != null) {
        state = state.copyWith(
          pickerData: picker,
          status: AuthStateStatus.authenticated,
          error: null,
        );
      } else {
        state = state.copyWith(
          pickerData: null,
          status: AuthStateStatus.unauthenticated,
          error: null,
        );
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = state.copyWith(status: AuthStateStatus.loading, error: null);

      _authFunctions.signIn(email: email, password: password).listen((data) {
        switch (data.status) {
          case Status.loading:
            state = state.copyWith(
              status: AuthStateStatus.loading,
              error: null,
            );
            break;
          case Status.success:
            state = state.copyWith(
              status: AuthStateStatus.authenticated,
              pickerData: data.picker,
              error: null,
            );
            _obAuthService.setPicker(data.picker!);
            break;
          case Status.error:
            state = state.copyWith(
              status: AuthStateStatus.error,
              error: data.message,
            );
            break;
        }
      });
    } catch (e) {
      CustomSnackBar.log(
        status: SnackBarType.error,
        message: "Failed to login",
      );
      state = state.copyWith(
        error: e.toString(),
        status: AuthStateStatus.error,
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      state = state.copyWith(status: AuthStateStatus.loading, error: null);

      _authFunctions
          .signUp(email: email, password: password, name: name, phone: phone)
          .listen((data) {
            switch (data.status) {
              case Status.loading:
                state = state.copyWith(
                  status: AuthStateStatus.loading,
                  error: null,
                );
                break;
              case Status.success:
                state = state.copyWith(
                  status: AuthStateStatus.authenticated,
                  pickerData: data.picker,
                  error: null,
                );
                _obAuthService.setPicker(data.picker!);
                break;
              case Status.error:
                state = state.copyWith(
                  status: AuthStateStatus.error,
                  error: data.message,
                );
                break;
            }
          });
    } catch (e) {
      CustomSnackBar.log(
        status: SnackBarType.error,
        message: "Failed to signup",
      );
      state = state.copyWith(
        error: e.toString(),
        status: AuthStateStatus.error,
      );
    }
  }

  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStateStatus.loading, error: null);
      final email = await _authFunctions.getEmailByPhone(phone);
      if (email == null) {
        state = state.copyWith(
          status: AuthStateStatus.error,
          error: 'No user found with this phone number',
        );
        CustomSnackBar.log(
          status: SnackBarType.error,
          message: 'No user found with this phone number',
        );
        return;
      }
      _authFunctions.signIn(email: email, password: password).listen((data) {
        switch (data.status) {
          case Status.loading:
            state = state.copyWith(
              status: AuthStateStatus.loading,
              error: null,
            );
            break;
          case Status.success:
            state = state.copyWith(
              status: AuthStateStatus.authenticated,
              pickerData: data.picker,
              error: null,
            );
            break;
          case Status.error:
            state = state.copyWith(
              status: AuthStateStatus.error,
              error: data.message,
            );
            break;
        }
      });
    } catch (e) {
      CustomSnackBar.log(
        status: SnackBarType.error,
        message: "Failed to login with phone",
      );
      state = state.copyWith(
        error: e.toString(),
        status: AuthStateStatus.error,
      );
    }
  }

  Future<void> signOut() async {
    await _authFunctions.signOut();
    SyncService(objectbox: objectbox!).clearBox();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
