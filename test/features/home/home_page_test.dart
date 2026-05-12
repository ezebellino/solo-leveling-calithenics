import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_controller.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_state.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_session.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/pages/home_page.dart';
import 'package:solo_leveling_calisthenics/features/player/application/bootstrap_player_controller.dart';
import 'package:solo_leveling_calisthenics/features/player/application/bootstrap_player_state.dart';

void main() {
  group('HomePage auth gate', () {
    testWidgets('shows restoring message while auth session is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionControllerProvider.overrideWith(_RestoringAuthSessionController.new),
            bootstrapPlayerControllerProvider.overrideWith(_IdleBootstrapPlayerController.new),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.text('Restaurando acceso del Sistema...'), findsOneWidget);
      expect(find.byType(AppShellPage), findsNothing);
    });

    testWidgets('shows auth access page when there is no active session', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionControllerProvider.overrideWith(_UnauthenticatedAuthSessionController.new),
            bootstrapPlayerControllerProvider.overrideWith(_IdleBootstrapPlayerController.new),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.text('Acceso del Sistema'), findsOneWidget);
      expect(find.byType(AppShellPage), findsNothing);
    });

    testWidgets('shows app shell when auth session is authenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionControllerProvider.overrideWith(_AuthenticatedAuthSessionController.new),
            bootstrapPlayerControllerProvider.overrideWith(_IdleBootstrapPlayerController.new),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      expect(find.byType(AppShellPage), findsOneWidget);
    });
  });
}

class _RestoringAuthSessionController extends AuthSessionController {
  @override
  AuthSessionState build() => const AuthSessionState(isRestoring: true);

  @override
  Future<void> initialize() async {}
}

class _UnauthenticatedAuthSessionController extends AuthSessionController {
  @override
  AuthSessionState build() => const AuthSessionState(
        isRestoring: false,
        providers: [],
      );

  @override
  Future<void> initialize() async {}
}

class _AuthenticatedAuthSessionController extends AuthSessionController {
  @override
  AuthSessionState build() => AuthSessionState(
        isRestoring: false,
        providers: const [],
        session: AuthSession(
          accessToken: 'access-token',
          provider: 'google',
          expiresAt: DateTime.utc(2026, 5, 12, 18),
          userId: 'user-1',
          displayName: 'Hunter',
          avatarUrl: '',
          email: 'hunter@example.com',
        ),
      );

  @override
  Future<void> initialize() async {}
}

class _IdleBootstrapPlayerController extends BootstrapPlayerController {
  @override
  BootstrapPlayerState build() => const BootstrapPlayerState();

  @override
  Future<void> load() async {}
}
