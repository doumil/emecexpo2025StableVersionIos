// lib/login_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/main.dart'; // Assuming WelcomPage is defined here
import 'package:url_launcher/url_launcher.dart';
import 'api_services/auth_api_service.dart'; // Contains sendVerificationCode, verifyCode, and NEW: forgetPassword
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
  String? _validatedEmail; // Stores email after successful code send/forget password
  LoginStep _currentStep = LoginStep.enterEmail;

  void _goToStep2(String email) {
    setState(() {
      _validatedEmail = email;
      _currentStep = LoginStep.verifyCode;
      // Ensure the shared controller has the email when entering Step 2
      if (_emailController.text != email) {
        _emailController.text = email;
      }
    });
  }

  void _goToStep3() {
    setState(() {
      _currentStep = LoginStep.forgetPassword;
      // **[MODIFIED]** Only clear the email field if it was empty,
      // otherwise keep the email already entered in Step 1/Step 2
      if (_validatedEmail != null && _emailController.text.isEmpty) {
        _emailController.text = _validatedEmail!;
      }
    });
  }

  // Refactored to handle returning to step 1 from any other step
  void _goToStep1() {
    setState(() {
      // Keep the email in the controller if it's already validated
      if (_validatedEmail != null) {
        _emailController.text = _validatedEmail!;
      } else {
        _emailController.clear();
      }
      _validatedEmail = null;
      _currentStep = LoginStep.enterEmail;
    });
  }

  // Used by Step 3 (Forget Password) to transition to Step 2 (Verify)
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
      // Ensure email is present before building Step 2
        if (_validatedEmail == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToStep1());
          currentStepWidget = const Center(child: CircularProgressIndicator());
        } else {
          currentStepWidget = LoginStep2(
            key: const ValueKey('step2'),
            email: _validatedEmail!,
            onBack: _goToStep1, // Back button goes to step 1
            onResendCode: _goToStep3, // Resend button now directs to the Forget Password flow
          );
        }
        break;
      case LoginStep.forgetPassword:
        currentStepWidget = LoginStep3(
          key: const ValueKey('step3'),
          emailController: _emailController, // Use main controller for input
          onSuccess: _goToStep2FromForget, // Success goes to verify code (Step 2)
          onBack: _goToStep1, // Back button goes to step 1
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
              // Logo/Header Area
              Image.asset(
                'assets/EMEC-LOGO.png',
                height: 120,
              ),
              const SizedBox(height: 48.0),

              // Step Widget
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentStepWidget,
              ),
              const SizedBox(height: 24.0),

              // Footer Links
              // 1. Forgot Password Link (Goes to Step 3)
              // The user requested to hide this link by commenting it out.
              /*
              TextButton(
                onPressed: _goToStep3,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.secondaryColor),
                ),
              ),
              */

              // 2. Register Link
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

  // --- Design Implementation (Full-Screen Background) ---
  Widget _buildLoginBackground(BuildContext context, Widget child) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: [
          // Background Image
/*          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background_login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),*/
          // Gradient Overlay
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
          // Content
          child,
        ],
      ),
    );
  }

  Future<void> _launchUrlRegister() async {
    final Uri url = Uri.parse('https://www.emecexpo.com/tickets/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch ticket.')),
        );
      }
      throw Exception('Could not launch url');
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
    // Prevent API call if local validation fails
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard while loading
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final AuthApiService authService = AuthApiService();
    // 💡 API Call for LOGIN verification code
    final Map<String, dynamic> result = await authService.sendVerificationCode(
      widget.emailController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Verification code sent to email.')),
        );
        widget.onSuccess(widget.emailController.text);
      } else {
        // Show error dialog with specific error message if API fails (e.g., email not found)
        _showErrorDialog(
          result['message'] ?? 'The provided email address is not registered.',
        );
      }
    }
  }

  // Error dialog with clear field and refocus logic
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Clear the email field
              widget.emailController.clear();
              // Set focus back to the email field
              _emailFocusNode.requestFocus();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final Color inputFillColor = theme.whiteColor;
    final Color inputTextColor = theme.blackColor;
    final Color inputHintIconColor = theme.blackColor.withOpacity(0.6);
    final Color borderColor = theme.whiteColor.withOpacity(0.5);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In with your Email',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.whiteColor),
          ),
          const SizedBox(height: 24.0),
          // Email Input Field
          TextFormField(
            controller: widget.emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: inputTextColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: 'Write your email address',
              hintStyle: TextStyle(color: inputHintIconColor),
              prefixIcon: Icon(Icons.email, color: inputHintIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.secondaryColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            ),
            // STRICT EMAIL VALIDATION
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }

              // Strict regex check for a valid email format
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address (e.g., user@domain.com)';
              }

              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Generate One-Time Password Button
          _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.secondaryColor))
              : ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Generate a one-time password',
              style: TextStyle(
                fontSize: 18.0,
                color: theme.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// --- STEP 2: Verify Code (Common to Login/Forget) ---
// =======================================================

class LoginStep2 extends StatefulWidget {
  final String email;
  final VoidCallback onBack;
  final VoidCallback onResendCode; // New callback for resend logic

  const LoginStep2({
    required Key key,
    required this.email,
    required this.onBack,
    required this.onResendCode,
  }) : super(key: key);

  @override
  _LoginStep2State createState() => _LoginStep2State();
}

class _LoginStep2State extends State<LoginStep2> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _codeFocusNode = FocusNode();


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verification Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _codeController.clear();
              _codeFocusNode.requestFocus();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  Future<void> _verifyCodeAndLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final AuthApiService authService = AuthApiService();
    final Map<String, dynamic> result = await authService.verifyCode(
      widget.email,
      _codeController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        final User loggedInUser = result['user'];
        // Save user data (if necessary, though not explicitly requested)
        // For demonstration, we just navigate:

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => WelcomPage(user: loggedInUser),
          ),
              (Route<dynamic> route) => false,
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Invalid verification code.');
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final Color inputFillColor = theme.whiteColor;
    final Color inputTextColor = theme.blackColor;
    final Color inputHintIconColor = theme.blackColor.withOpacity(0.6);
    final Color borderColor = theme.whiteColor.withOpacity(0.5);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Back button to return to Step 1
              /* IconButton(
                icon: Icon(Icons.arrow_back, color: theme.whiteColor),
                onPressed: widget.onBack,
              ),*/
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Code sent to: ${widget.email}',
                    style: TextStyle(color: theme.whiteColor, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          Text(
            'Enter the password',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.whiteColor.withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 8.0),

          // Code Input Field
          TextFormField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            keyboardType: TextInputType.text, // Normal keyboard for easy input
            textAlign: TextAlign.center,
            style: TextStyle(color: inputTextColor, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: 'Password',
              hintStyle: TextStyle(color: inputHintIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.secondaryColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length != 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          // Verify Button
          _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.secondaryColor))
              : ElevatedButton(
            onPressed: _verifyCodeAndLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Verify and Login',
              style: TextStyle(
                fontSize: 18.0,
                color: theme.whiteColor,
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          // Resend/Forget Password Link
          TextButton(
            onPressed: widget.onResendCode, // New action goes to forget password flow
            child: Text(
              // **[MODIFIED]** Removed "Forgot Password" text
              'Didn\'t receive the code? Resend',
              style: TextStyle(color: theme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// --- STEP 3: Forget Password (New) ---
// =======================================================

class LoginStep3 extends StatefulWidget {
  final TextEditingController emailController;
  final Function(String email) onSuccess;
  final VoidCallback onBack;

  const LoginStep3({
    required Key key,
    required this.emailController,
    required this.onSuccess,
    required this.onBack,
  }) : super(key: key);

  @override
  _LoginStep3State createState() => _LoginStep3State();
}

class _LoginStep3State extends State<LoginStep3> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestNewCode() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final AuthApiService authService = AuthApiService();
    // 💡 API Call for FORGET PASSWORD (Requests a NEW verification code)
    final Map<String, dynamic> result = await authService.forgetPassword(
      widget.emailController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'A new verification code has been sent.')),
        );
        // On success, go to Step 2 to verify the NEW code
        widget.onSuccess(widget.emailController.text);
      } else {
        _showErrorDialog(
          result['message'] ?? 'Could not find the email or an error occurred.',
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password Reset Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _emailFocusNode.requestFocus();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final Color inputFillColor = theme.whiteColor;
    final Color inputTextColor = theme.blackColor;
    final Color inputHintIconColor = theme.blackColor.withOpacity(0.6);
    final Color borderColor = theme.whiteColor.withOpacity(0.5);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Back button to return to Step 1
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(color: theme.whiteColor, fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          Text(
            'Enter your email to receive a new one-time password.',
            textAlign: TextAlign.start,
            style: TextStyle(color: theme.whiteColor.withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 16.0),

          // Email Input Field
          TextFormField(
            controller: widget.emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: inputTextColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: 'Registered email address',
              hintStyle: TextStyle(color: inputHintIconColor),
              prefixIcon: Icon(Icons.email, color: inputHintIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.secondaryColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address (e.g., user@domain.com)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),

          // Request New Code Button
          _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.secondaryColor))
              : ElevatedButton(
            onPressed: _requestNewCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Send New Password',
              style: TextStyle(
                fontSize: 18.0,
                color: theme.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}