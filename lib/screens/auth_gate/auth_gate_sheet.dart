import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_gate_controller.dart';
import 'auth_gate_provider.dart';
import 'auth_gate_strings.dart';

class AuthGateSheet extends ConsumerStatefulWidget {
  const AuthGateSheet({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthGateSheet> createState() => _AuthGateSheetState();
}

class _AuthGateSheetState extends ConsumerState<AuthGateSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authUserChangesProvider);
    final gateState = ref.watch(authGateControllerProvider);
    final controller = ref.read(authGateControllerProvider.notifier);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    final isAuthorized = authState.asData?.value != null;
    if (isAuthorized) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        const ModalBarrier(dismissible: false, color: Color(0x9E000000)),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: SafeArea(
              top: false,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, -4)),
                      ],
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AuthGateStrings.title,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            AuthGateStrings.subtitle,
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text(AuthGateStrings.loginTab),
                                icon: Icon(Icons.login),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text(AuthGateStrings.registerTab),
                                icon: Icon(Icons.person_add_alt_1),
                              ),
                            ],
                            selected: {gateState.isRegisterMode},
                            onSelectionChanged: (selection) {
                              controller.setRegisterMode(selection.first);
                            },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !gateState.isLoading,
                            decoration: const InputDecoration(
                              labelText: AuthGateStrings.emailLabel,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            enabled: !gateState.isLoading,
                            decoration: const InputDecoration(
                              labelText: AuthGateStrings.passwordLabel,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (gateState.errorText != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              gateState.errorText!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: gateState.isLoading
                                  ? null
                                  : () => controller.submitAuth(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                              child: gateState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      gateState.isRegisterMode
                                          ? AuthGateStrings.createAccountButton
                                          : AuthGateStrings.signInButton,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
