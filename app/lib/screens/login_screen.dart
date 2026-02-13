import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/gradient_background.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registerMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_registerMode) {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            email: email,
            password: password,
            displayName: _nameController.text.trim(),
          );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);
  }

  void _toggleMode() {
    setState(() {
      _registerMode = !_registerMode;
    });
  }

  String? _authErrorMessage(AsyncValue<UserSession?> authState) {
    final error = authState.asError?.error;
    if (error == null) {
      return null;
    }
    final value = error.toString();
    if (value.contains('register')) {
      return 'Could not create account. Check details and try again.';
    }
    if (value.contains('login')) {
      return 'Login failed. Check email and password.';
    }
    if (value.contains('Exception:')) {
      return value.replaceFirst('Exception:', '').trim();
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;
    final errorMessage = _authErrorMessage(authState);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: PageLayout(
            maxWidth: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Arivest',
                  subtitle: 'Arivu for smart investing.',
                ),
                const SizedBox(height: 20),
                Text(
                  _registerMode ? 'Create your account' : 'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync your learning progress across devices.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_registerMode) ...[
                            Text(
                              'New learner details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Display name (optional)',
                              ),
                            ),
                          ],
                          if (!_registerMode) ...[
                            Text(
                              'Account login',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'name@example.com',
                            ),
                            validator: (value) {
                              final input = (value ?? '').trim();
                              if (input.isEmpty) {
                                return 'Enter your email';
                              }
                              if (!input.contains('@') ||
                                  !input.contains('.')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Minimum 8 characters',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final input = (value ?? '').trim();
                              if (input.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isSubmitting ? null : _submit,
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _registerMode
                                          ? 'Create account'
                                          : 'Login',
                                    ),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              errorMessage,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: isSubmitting ? null : _toggleMode,
                              child: Text(
                                _registerMode
                                    ? 'Have an account? Login'
                                    : 'New here? Create account',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const PolicyNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
