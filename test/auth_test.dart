import 'package:flutter_test/flutter_test.dart';
import 'package:zynotes/services/auth/auth_exceptions.dart';
import 'package:zynotes/services/auth/auth_provider.dart';
import 'package:zynotes/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized first', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot signout if not initialized', () {
      expect(provider.signOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Cannot create user if not initialized', () {
      expect(provider.createUser(email: 'test', password: 'test'),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Cannot login if not initialized', () {
      expect(provider.signIn(email: 'test', password: 'test'),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to initialize within 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Create user should delegate to login', () async {
      final badEmailUser = provider.createUser(
        email: 'bad@email.com',
        password: 'test',
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword = provider.createUser(
        email: 'email@email.com',
        password: 'badPassword',
      );
      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'email@email.com',
        password: 'testPassword',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.signOut();
      await provider.signIn(
        email: 'email@email.com',
        password: 'testPassword',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  bool _isInitialized = false;
  AuthUser? _user;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(id: 'my_id', email: 'email@email.com', isEmailVerified: true);
    _user = newUser;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'bad@email.com') throw UserNotFoundAuthException();
    if (password == 'badPassword') throw WrongPasswordAuthException();
    const user =
        AuthUser(id: 'my_id', email: 'email@email.com', isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> signOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }
}
