import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'layouts/error.page.dart';
import 'layouts/login_signup.dart';
import 'layouts/navigation.dart';
import 'models/auth_state.model.dart';
import 'providers/auth.provider.dart';

class AuthShifter extends ConsumerWidget {
  const AuthShifter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthState authState = ref.watch(authProvider);
    switch (authState.status) {
      case AuthStateStatus.authenticated:
        return Navigation();
      case AuthStateStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AuthStateStatus.unauthenticated:
        return LoginSignupPage();
      case AuthStateStatus.wrongUser:
        return ErrorPage(errorMessage: authState.error);
      case AuthStateStatus.error:
        return ErrorPage(errorMessage: authState.error);
    }
  }
}
