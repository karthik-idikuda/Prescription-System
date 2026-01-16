import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _pin = [];
  bool _isLoading = false;
  String? _error;

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
        _error = null;
      });
      
      if (_pin.length == 4) {
        _login();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _error = null;
      });
    }
  }

  void _clearPin() {
    setState(() {
      _pin.clear();
      _error = null;
    });
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final pin = _pin.join();
    final success = await context.read<AuthProvider>().login(pin);

    setState(() => _isLoading = false);

    if (!success && mounted) {
      setState(() {
        _error = 'Wrong PIN. Try again.';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Logo & Title
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_pharmacy,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pharmacy App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // PIN Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Error message
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              
              const SizedBox(height: 40),

              // Number Pad
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildNumberPad(),

              const Spacer(),

              // Hint
              Text(
                'Default PIN: 1234',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['1', '2', '3'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['4', '5', '6'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['7', '8', '9'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionKey(Icons.clear, _clearPin),
            _buildKey('0'),
            _buildActionKey(Icons.backspace, _removeDigit),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: () => _addDigit(digit),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, size: 28, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
