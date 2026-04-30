// lib/login_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/main.dart'; // Assuming WelcomPage is defined here
import 'package:url_launcher/url_launcher.dart';
import 'api_services/auth_api_service.dart'; // Contains sendVerificationCode, verifyCode, and forgetPassword
import 'model/app_theme_data.dart'; // Assuming this defines your theme structure

// --- Step Enum for State Management ---
enum LoginStep { enterEmail, verifyCode, forgetPassword }

// --- Main Widget for Step Management ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Shared state for the login flow
  final TextEditingController _emailController = TextEditingController();
  String? _validatedEmail;
  LoginStep _currentStep = LoginStep.enterEmail;

  void _goToStep2(String email) {
    setState(() {
      _validatedEmail = email;
      _currentStep = LoginStep.verifyCode;
      if (_emailController.text != email) {
        _emailController.text = email;
      }
    });
  }

  void _goToStep3() {
    setState(() {
      _currentStep = LoginStep.forgetPassword;
      if (_validatedEmail != null && _emailController.text.isEmpty) {
        _emailController.text = _validatedEmail!;
      }
    });
  }

  void _goToStep1() {
    setState(() {
      if (_validatedEmail != null) {
        _emailController.text = _validatedEmail!;
      } else {
        _emailController.clear();
      }
      _validatedEmail = null;
      _currentStep = LoginStep.enterEmail;
    });
  }

  void _goToStep2FromForget(String email) {
    setState(() {
      _validatedEmail = email;
      _currentStep = LoginStep.verifyCode;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentStepWidget;
    switch (_currentStep) {
      case LoginStep.enterEmail:
        currentStepWidget = LoginStep1(
          key: const ValueKey('step1'),
          emailController: _emailController,
          onSuccess: _goToStep2,
        );
        break;
      case LoginStep.verifyCode:
        if (_validatedEmail == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToStep1());
          currentStepWidget = const Center(child: CircularProgressIndicator());
        } else {
          currentStepWidget = LoginStep2(
            key: const ValueKey('step2'),
            email: _validatedEmail!,
            onBack: _goToStep1,
            onResendCode: _goToStep3,
          );
        }
        break;
      case LoginStep.forgetPassword:
        currentStepWidget = LoginStep3(
          key: const ValueKey('step3'),
          emailController: _emailController,
          onSuccess: _goToStep2FromForget,
          onBack: _goToStep1,
        );
        break;
    }

    return _buildLoginBackground(
      context,
      Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/EMEC-LOGO.png',
                height: 120,
              ),
              const SizedBox(height: 48.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentStepWidget,
              ),
              const SizedBox(height: 24.0),
              TextButton(
                onPressed: () => _launchUrlRegister(),
                child: Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBackground(BuildContext context, Widget child) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.blackColor.withOpacity(0.4),
                    theme.blackColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Future<void> _launchUrlRegister() async {
    final Uri url = Uri.parse('https://www.emecexpo.com/tickets/');

    try {
      // platformDefault هي أفضل طريقة حالياً
      // كتفتح Safari View Controller في الأيفون تلقائياً
      if (!await launchUrl(
        url,
        mode: LaunchMode.platformDefault,
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

// =======================================================
// --- STEP 1: Enter Email Only (Login) ---
// =======================================================

class LoginStep1 extends StatefulWidget {
  final TextEditingController emailController;
  final Function(String email) onSuccess;

  const LoginStep1({
    required Key key,
    required this.emailController,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _LoginStep1State createState() => _LoginStep1State();
}

class _LoginStep1State extends State<LoginStep1> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; });

    final AuthApiService authService = AuthApiService();
    final Map<String, dynamic> result = await authService.sendVerificationCode(widget.emailController.text);

    if (mounted) {
      setState(() { _isLoading = false; });
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Verification code sent.')));
        widget.onSuccess(widget.emailController.text);
      } else {
        _showErrorDialog(result['message'] ?? 'Email not registered.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Authentication Error'),
      content: Text(message),
      actions: [TextButton(onPressed: () { Navigator.pop(ctx); _emailFocusNode.requestFocus(); }, child: const Text('Okay'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sign In with your Email', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.whiteColor)),
          const SizedBox(height: 24.0),
          TextFormField(
            controller: widget.emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.blackColor),
            decoration: InputDecoration(
              filled: true, fillColor: theme.whiteColor,
              hintText: 'Write your email address',
              prefixIcon: Icon(Icons.email, color: theme.blackColor.withOpacity(0.6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 18.0)),
            child: Text('Generate a one-time password', style: TextStyle(fontSize: 18.0, color: theme.whiteColor)),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// --- STEP 2: Verify Code ---
// =======================================================

class LoginStep2 extends StatefulWidget {
  final String email;
  final VoidCallback onBack;
  final VoidCallback onResendCode;

  const LoginStep2({required Key key, required this.email, required this.onBack, required this.onResendCode}) : super(key: key);

  @override
  _LoginStep2State createState() => _LoginStep2State();
}

class _LoginStep2State extends State<LoginStep2> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _codeFocusNode = FocusNode();

  Future<void> _verifyCodeAndLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; });

    final AuthApiService authService = AuthApiService();
    final Map<String, dynamic> result = await authService.verifyCode(widget.email, _codeController.text);

    if (mounted) {
      setState(() { _isLoading = false; });
      if (result['success'] == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => WelcomPage(user: result['user'])),
              (route) => false,
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Invalid code.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Okay'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Code sent to: ${widget.email}', style: TextStyle(color: theme.whiteColor)),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.blackColor, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(filled: true, fillColor: theme.whiteColor, hintText: 'Password'),
            validator: (value) => (value == null || value.length != 6) ? 'Enter 6 digits' : null,
          ),
          const SizedBox(height: 24.0),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
            onPressed: _verifyCodeAndLogin,
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 18.0)),
            child: Text('Verify and Login', style: TextStyle(color: theme.whiteColor)),
          ),
          TextButton(onPressed: widget.onResendCode, child: Text('Didn\'t receive the code? Resend', style: TextStyle(color: theme.secondaryColor))),
        ],
      ),
    );
  }
}

// =======================================================
// --- STEP 3: Forget Password ---
// =======================================================

class LoginStep3 extends StatefulWidget {
  final TextEditingController emailController;
  final Function(String email) onSuccess;
  final VoidCallback onBack;

  const LoginStep3({required Key key, required this.emailController, required this.onSuccess, required this.onBack}) : super(key: key);

  @override
  _LoginStep3State createState() => _LoginStep3State();
}

class _LoginStep3State extends State<LoginStep3> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _requestNewCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    final result = await AuthApiService().forgetPassword(widget.emailController.text);
    if (mounted) {
      setState(() { _isLoading = false; });
      if (result['success'] == true) {
        widget.onSuccess(widget.emailController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            IconButton(icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), onPressed: widget.onBack),
            Text('Forgot Password', style: TextStyle(color: theme.whiteColor, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: widget.emailController,
            style: TextStyle(color: theme.blackColor),
            decoration: InputDecoration(filled: true, fillColor: theme.whiteColor, hintText: 'Registered email'),
            validator: (value) => (value == null || value.isEmpty) ? 'Enter email' : null,
          ),
          const SizedBox(height: 24.0),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
            onPressed: _requestNewCode,
            child: Text('Send New Password'),
          ),
        ],
      ),
    );
  }
}