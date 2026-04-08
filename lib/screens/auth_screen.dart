import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = false;
  String _name = '';
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authController = ref.read(authControllerProvider.notifier);
      
      try {
        if (_isLogin) {
          await authController.signIn(_email, _password);
        } else {
          await authController.signUp(_email, _password, _name);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Text('P', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('Welcome to PayU', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Send money globally with the real exchange rate', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 48),
              const Text('Get started', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Sign in to your account or create a new one', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              
              // Auth Mode Toggle
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text('Sign In', 
                              style: TextStyle(color: _isLogin ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text('Sign Up', 
                              style: TextStyle(color: !_isLogin ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isLogin) ...[
                      const Text('Full Name', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Enter your full name'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                        onSaved: (v) => _name = v!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text('Email', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Enter your email'),
                      validator: (value) => !value!.contains('@') ? 'Invalid email' : null,
                      onSaved: (v) => _email = v!,
                    ),
                    const SizedBox(height: 16),
                    const Text('Password', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: _inputDecoration(_isLogin ? 'Enter your password' : 'Create a password'),
                      validator: (value) => value!.length < 6 ? 'Too short' : null,
                      onSaved: (v) => _password = v!,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      const Text('Confirm Password', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: _inputDecoration('Confirm your password'),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                        : Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
