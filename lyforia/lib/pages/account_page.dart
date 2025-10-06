import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lyforia/utils/firebase_refs.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.length < 6) {
      _toast('Enter email and 6+ char password');
      return;
    }
    setState(() => _busy = true);
    try {
      await Fb.auth
          .signInWithEmailAndPassword(email: email, password: password);
      _toast('Signed in as $email');
    } on FirebaseAuthException catch (e) {
      _toast(_formatAuthError(action: 'Sign-in', error: e));
    } catch (e) {
      _toast('Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.length < 6) {
      _toast('Enter email and 6+ char password');
      return;
    }
    setState(() => _busy = true);
    try {
      await Fb.auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _toast('Account created');
    } on FirebaseAuthException catch (e) {
      _toast(_formatAuthError(action: 'Sign-up', error: e));
    } catch (e) {
      _toast('Sign-up failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await Fb.auth.signOut();
      // Also sign out from Google if used
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      _toast('Signed out');
    } catch (e) {
      _toast('Sign-out failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _toast('Enter your email to reset password');
      return;
    }
    setState(() => _busy = true);
    try {
      await Fb.auth.sendPasswordResetEmail(email: email);
      _toast('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      _toast(_formatAuthError(action: 'Reset', error: e));
    } catch (e) {
      _toast('Reset failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatAuthError(
      {required String action, required FirebaseAuthException error}) {
    switch (error.code) {
      case 'email-already-in-use':
        return '$action failed: Email already in use. Try Sign In or Google.';
      case 'invalid-email':
        return '$action failed: Invalid email address.';
      case 'weak-password':
        return '$action failed: Password too weak (min 6 chars recommended).';
      case 'user-not-found':
        return '$action failed: No user found. Try Create Account.';
      case 'wrong-password':
        return '$action failed: Wrong password. Try Reset Password.';
      case 'network-request-failed':
        return '$action failed: Network error. Check your connection.';
      case 'operation-not-allowed':
        return '$action failed: Provider disabled in Firebase Console.';
      case 'too-many-requests':
        return '$action failed: Too many attempts. Please wait and retry.';
      default:
        return '$action failed: ${error.code}';
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user == null) {
        // Cancelled by user
        return;
      }
      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await Fb.auth.signInWithCredential(credential);
      _toast('Signed in with Google as ${user.email}');
    } on PlatformException catch (e) {
      final msg = e.message ?? e.code;
      if (msg.contains('ApiException: 10')) {
        _toast(
            'Google sign-in setup issue (code 10). See README Google Sign-In steps.');
      } else {
        _toast('Google sign-in failed: ${e.code}');
      }
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: StreamBuilder(
        stream: Fb.auth.authStateChanges(),
        builder: (context, snapshot) {
          final user = Fb.auth.currentUser;
          if (user != null) {
            return _buildSignedIn(user.email, user.uid);
          }
          return _buildAuthForm();
        },
      ),
    );
  }

  Widget _buildAuthForm() {
    final theme = Theme.of(context);
    final spinner = SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
      ),
    );
    return AbsorbPointer(
      absorbing: _busy,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: _busy ? spinner : const Text('Sign In'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _register,
              child: const Text('Create Account'),
            ),
            TextButton(
              onPressed: _resetPassword,
              child: const Text('Forgot password?'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedIn(String? email, String uid) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signed in', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Email: ${email ?? 'N/A'}'),
          Text('UID: $uid'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signOut,
              child: _busy
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}
