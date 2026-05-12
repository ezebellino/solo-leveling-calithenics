import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth_session_controller.dart';
import '../../application/auth_session_state.dart';
import '../../../home/presentation/widgets/section_palette.dart';

class AuthAccessPage extends ConsumerStatefulWidget {
  const AuthAccessPage({super.key});

  @override
  ConsumerState<AuthAccessPage> createState() => _AuthAccessPageState();
}

class _AuthAccessPageState extends ConsumerState<AuthAccessPage> {
  static const _palette = SectionPalette(
    primary: Color(0xFF79E7FF),
    secondary: Color(0xFF25F3B4),
    highlight: Color(0xFFF2FFFF),
  );

  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _magicLinkTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(authSessionControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _magicLinkTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authSessionControllerProvider);
    final controller = ref.read(authSessionControllerProvider.notifier);

    if (state.magicLinkPreviewToken != null &&
        _magicLinkTokenController.text.isEmpty) {
      _magicLinkTokenController.text = state.magicLinkPreviewToken!;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050910),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xCC08131F),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _palette.primary.withValues(alpha: 0.32)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 30,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildContent(context, state, controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthSessionState state,
    AuthSessionController controller,
  ) {
    if (state.isRestoring) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text(
            'Restaurando acceso del cazador...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Acceso del Sistema',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          state.isAuthenticated
              ? 'La cuenta ya tiene una sesion activa. Desde aqui podemos validar Google, magic link y restauracion local.'
              : 'Preparamos el ingreso con Google y magic link, dejando una sesion durable para conservar el historial del jugador.',
          style: const TextStyle(
            color: Color(0xFFB9C7D6),
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        if (state.errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x332A1010),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF7D7D)),
            ),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Color(0xFFFFCACA)),
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (state.providers.isNotEmpty) ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: state.providers
                .map(
                  (provider) => Chip(
                    label: Text(provider.displayName),
                    avatar: Icon(
                      provider.code == 'google'
                          ? Icons.account_circle_rounded
                          : Icons.mark_email_unread_rounded,
                      size: 18,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 22),
        ],
        TextField(
          controller: _displayNameController,
          decoration: const InputDecoration(
            labelText: 'Alias del jugador',
            hintText: 'Eze Bellino',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'hunter@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () => controller.signInWithGooglePreview(
                        email: _emailController.text.trim(),
                        displayName: _displayNameController.text.trim(),
                      ),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Continuar con Google'),
            ),
            OutlinedButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () => controller.requestMagicLink(
                        email: _emailController.text.trim(),
                        displayName: _displayNameController.text.trim(),
                      ),
              icon: const Icon(Icons.mark_email_read_rounded),
              label: const Text('Solicitar Magic Link'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _magicLinkTokenController,
          decoration: const InputDecoration(
            labelText: 'Magic link preview token',
            hintText: 'Pega aqui el token de verificacion',
          ),
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: state.isSubmitting
              ? null
              : () => controller.verifyMagicLink(
                    token: _magicLinkTokenController.text.trim(),
                  ),
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Verificar Magic Link'),
        ),
        if (state.magicLinkPreviewToken != null) ...[
          const SizedBox(height: 16),
          SelectableText(
            'Preview token listo para pruebas locales:\n${state.magicLinkPreviewToken!}',
            style: const TextStyle(
              color: Color(0xFFBDE8FF),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
        if (state.session != null) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x2218A8A3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _palette.secondary.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesion autenticada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.session!.displayName} • ${state.session!.email ?? 'sin email'}',
                  style: const TextStyle(color: Color(0xFFDFF9FF)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Proveedor: ${state.session!.provider} • Expira: ${state.session!.expiresAt.toLocal()}',
                  style: const TextStyle(color: Color(0xFFA3C8D5), fontSize: 13),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: state.isSubmitting ? null : controller.signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesion'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
