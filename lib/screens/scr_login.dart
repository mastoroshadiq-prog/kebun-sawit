// screens/login_screen.dart (Versi Lebih Cantik & Elegan)
import 'package:flutter/material.dart';
import '../../screens/widgets/w_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward(); // Mulai animasi saat screen dimuat
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Latar Belakang Gradient yang Elegan
          Positioned.fill(child: contLatarBelakang(),),
          Positioned.fill(child: boxLatarBelakang(),),
          // 2. Konten Login
          loginContent(
              _usernameController,
              _passwordController,
              _animation, context,
              '/initSync', '/sqlite'
          ),
        ],
      ),
    );
  }
}