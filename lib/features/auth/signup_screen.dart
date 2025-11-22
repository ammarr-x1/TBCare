import 'package:flutter/material.dart';
import 'package:tbcare_main/features/auth/services/signup_service.dart';
import 'package:tbcare_main/core/app_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _roles = ['Patient', 'CHW', 'Doctor', 'Admin'];
  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16, color: secondaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: secondaryColor.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole!;

    final error = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
      status: "Active",
      flagged: false,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushNamed(context, '/verify');
    }
  }

  Widget _buildLogo(double screenHeight) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: screenHeight * 0.18,
            width: screenHeight * 0.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
              border: Border.all(color: primaryColor, width: 1),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Image.asset(
                  'assets/images/logo light.png',
                  fit: BoxFit.cover,
                  width: 120,   // increase width
                  height: 120,  // increase height
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Create Your Account',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildLogo(screenHeight),
                    const SizedBox(height: 30),
                    _buildTitle(),
                    const SizedBox(height: 32),

                    // Full Name
                    _buildField(_nameController, 'Full Name', Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your full name';
                          }
                          return null;
                        }),

                    const SizedBox(height: 16),

                    // Email
                    _buildField(_emailController, 'Email', Icons.email),

                    const SizedBox(height: 16),

                    // Password
                    _buildPasswordField(),

                    const SizedBox(height: 16),

                    // Role
                    Container(
                      constraints: BoxConstraints(maxWidth: 600),
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: _roles
                            .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role,
                              style: const TextStyle(color: secondaryColor)),
                        ))
                            .toList(),
                        decoration: _inputDecoration('Select role', Icons.person),
                        dropdownColor: bgColor,
                        iconEnabledColor: primaryColor,
                        onChanged: (value) =>
                            setState(() => _selectedRole = value),
                        validator: (value) =>
                        value == null ? 'Please select a role' : null,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign Up Button
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      width: double.infinity,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sign Up',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                            style: TextStyle(color: secondaryColor)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppConstants.loginRoute),
                          child: Text('Sign In',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon,
      {String? Function(String?)? validator}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: secondaryColor),
        decoration: _inputDecoration(hint, icon),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      width: double.infinity,
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: secondaryColor),
        decoration: _inputDecoration('Password', Icons.lock).copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: secondaryColor,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
