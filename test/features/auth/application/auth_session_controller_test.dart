import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_controller.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_state.dart';
import 'package:solo_leveling_calisthenics/features/auth/data/auth_repository_impl.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_provider_option.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_session.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_session_repository.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/magic_link_request_result.dart';

void main() {
  group('AuthSessionController', () {
    test('initialize leaves unauthenticated state when no session is stored', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [
          AuthProviderOption(
            code: 'google',
            displayName: 'Google',
            transport: 'oauth',
            availability: 'development_preview',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final states = <AuthSessionState>[];
      container.listen(
        authSessionControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.isRestoring, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.providers, hasLength(1));
      expect(states.any((entry) => entry.isRestoring), isTrue);
    });

    test('initialize restores authenticated session when a token is already cached', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [
          AuthProviderOption(
            code: 'magic_link',
            displayName: 'Magic Link',
            transport: 'email',
            availability: 'development_preview',
          ),
        ],
        restoredSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.session?.userId, _session.userId);
      expect(state.providers.single.code, 'magic_link');
    });

    test('signInWithGoogle stores authenticated session', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        googleSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).signInWithGoogle(
            email: 'hunter@example.com',
            displayName: 'Hunter',
          );

      final state = container.read(authSessionControllerProvider);
      expect(state.session?.userId, _session.userId);
      expect(state.session?.provider, 'google');
      expect(state.errorMessage, isNull);
    });

    test('requestMagicLink stores preview token for local verification flow', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        magicLinkResult: MagicLinkRequestResult(
          email: 'magic@example.com',
          expiresAt: DateTime.utc(2026, 5, 12, 12),
          delivery: 'preview',
          previewMode: true,
          previewToken: 'preview-token-123',
          verificationUrl: 'http://localhost:7358/auth?token=preview-token-123',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).requestMagicLink(
            email: 'magic@example.com',
            displayName: 'Magic User',
            redirectUrl: 'http://localhost:7358/auth',
          );

      final state = container.read(authSessionControllerProvider);
      expect(state.magicLinkPreviewToken, 'preview-token-123');
      expect(state.magicLinkEmail, 'magic@example.com');
      expect(state.magicLinkDelivery, 'preview');
      expect(state.magicLinkVerificationUrl, 'http://localhost:7358/auth?token=preview-token-123');
    });

    test('signOut clears the active session', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        googleSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).signInWithGoogle(
            email: 'hunter@example.com',
            displayName: 'Hunter',
          );
      await container.read(authSessionControllerProvider.notifier).signOut();

      final state = container.read(authSessionControllerProvider);
      expect(state.session, isNull);
      expect(repository.didSignOut, isTrue);
    });

    test('initialize stores mapped message when repository fails', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(
            _FakeAuthSessionRepository(
              providers: const [],
              providersError: const AppException(
                'auth_providers_failed',
                'No se pudo preparar el acceso.',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.errorMessage, 'No se pudo preparar el acceso.');
      expect(state.isRestoring, isFalse);
    });
  });
}

final _session = AuthSession(
  accessToken: 'access-token-123',
  provider: 'google',
  expiresAt: DateTime.utc(2026, 5, 12, 18),
  userId: 'user-1',
  displayName: 'Hunter',
  avatarUrl: '',
  email: 'hunter@example.com',
);

class _FakeAuthSessionRepository implements AuthSessionRepository {
  _FakeAuthSessionRepository({
    required this.providers,
    this.restoredSession,
    this.googleSession,
    this.magicLinkResult,
    this.providersError,
  });

  final List<AuthProviderOption> providers;
  final AuthSession? restoredSession;
  final AuthSession? googleSession;
  final MagicLinkRequestResult? magicLinkResult;
  final Object? providersError;

  bool didSignOut = false;

  @override
  Future<List<AuthProviderOption>> fetchProviders() async {
    if (providersError != null) {
      throw providersError!;
    }
    return providers;
  }

  @override
  Future<MagicLinkRequestResult> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
  }) async {
    return magicLinkResult!;
  }

  @override
  Future<AuthSession?> restoreSession() async => restoredSession;

  @override
  Future<AuthSession> signInWithGoogle({
    required String email,
    required String displayName,
  }) async {
    return googleSession!;
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }

  @override
  Future<AuthSession> verifyMagicLink({required String token}) async {
    return googleSession ?? _session;
  }
}
