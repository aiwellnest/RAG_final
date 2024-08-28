import 'package:ai_wellnest_frontend/provider/auth_provider.dart';
import 'package:ai_wellnest_frontend/screen/auth_screen/widgets/sign_in_alt_button.dart';
import 'package:ai_wellnest_frontend/screen/auth_screen/widgets/auth_button.dart';
import 'package:ai_wellnest_frontend/screen/auth_screen/widgets/auth_field.dart';
import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await authProvider.signIn(email, password);

      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.authErrorMessage ?? 'Sign in failed',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.authErrorMessage ?? 'Google Sign in failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: ColorPallete.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Text(
                  'Sign in.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      color: ColorPallete.whiteColor),
                ),
                const SizedBox(height: 50),
                SignInAltButton(
                  iconPath: 'assets/g_logo.svg',
                  label: 'Continue with Google',
                  onPressed: () => _handleGoogleSignIn(authProvider),
                ),
                const SizedBox(height: 15),
                const Text(
                  'or',
                  style:
                      TextStyle(fontSize: 17, color: ColorPallete.whiteColor),
                ),
                const SizedBox(height: 15),
                AuthField(
                  hintText: 'Email',
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                AuthField(
                  hintText: 'Password',
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _handleSignIn(authProvider);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                authProvider.isLoadingSignIn
                    ? const CircularProgressIndicator()
                    : AuthButton(
                        text: 'Sign in',
                        onPressed: () => _handleSignIn(authProvider),
                      ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: ColorPallete.whiteColor,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up now!',
                        style: const TextStyle(
                          color: ColorPallete.darkGreenColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.go('/signup');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
