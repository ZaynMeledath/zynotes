import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zynotes/services/auth/auth_provider.dart';
import 'package:zynotes/services/auth/bloc/auth_event.dart';
import 'package:zynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    //Initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    //Log in
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoading());
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.signIn(
          email: email,
          password: password,
        );
        if (user.isEmailVerified) {
          emit(AuthStateLoggedIn(user));
        } else {
          emit(const AuthStateNeedsVerification());
        }
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    //Log out
    on<AuthEventLogout>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.signOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
