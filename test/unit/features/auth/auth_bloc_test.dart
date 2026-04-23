import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/features/auth/domain/entities/auth_user.dart';
import 'package:route_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements AuthUser {}

void main() {
  late AuthRepository repository;
  late AuthUser user;

  setUp(() {
    repository = MockAuthRepository();
    user = MockUser();
    
    // Default mock behavior
    when(() => repository.onAuthStateChanged).thenAnswer((_) => Stream.value(null));
    when(() => repository.currentUser).thenReturn(null);
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(repository);
      expect(bloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when a user is found on init',
      build: () {
        when(() => repository.currentUser).thenReturn(user);
        when(() => repository.onAuthStateChanged).thenAnswer((_) => Stream.value(user));
        return AuthBloc(repository);
      },
      expect: () => [Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when no user is found on init',
      build: () {
        when(() => repository.currentUser).thenReturn(null);
        when(() => repository.onAuthStateChanged).thenAnswer((_) => Stream.value(null));
        return AuthBloc(repository);
      },
      expect: () => [Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when LogoutRequested is called',
      build: () {
        when(() => repository.currentUser).thenReturn(user);
        when(() => repository.onAuthStateChanged).thenAnswer((_) => Stream.value(null));
        when(() => repository.signOut()).thenAnswer((_) async {});
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [Unauthenticated()],
    );
  });
}
