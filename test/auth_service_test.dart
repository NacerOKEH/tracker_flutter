import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/features/auth/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('inscription crée un utilisateur', () async {
      final mockAuth = MockFirebaseAuth();
      final service = AuthService(auth: mockAuth);

      final credential = await service.register(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, equals('test@example.com'));
    });

    test('connexion retourne un utilisateur', () async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(email: 'test@example.com'),
        signedIn: false,
      );
      final service = AuthService(auth: mockAuth);

      final credential = await service.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credential.user, isNotNull);
    });

    test('déconnexion vide le currentUser', () async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(email: 'test@example.com'),
        signedIn: true,
      );
      final service = AuthService(auth: mockAuth);

      await service.signOut();

      expect(service.currentUser, isNull);
    });

    test('authStateChanges émet null quand déconnecté', () async {
      final mockAuth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(auth: mockAuth);

      expect(service.authStateChanges, emits(isNull));
    });
  });
}
