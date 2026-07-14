import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/main.dart';
import 'package:emecexpo/api_services/auth_api_service.dart';
import 'package:emecexpo/model/app_theme_data.dart';
import 'global/app_config.dart';

enum LoginStep { enterEmail, verifyCode, forgetPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _validatedEmail;
  LoginStep _currentStep = LoginStep.enterEmail;

  void _goToStep2(String email) {
    setState(() {
      _validatedEmail = email;
      _currentStep = LoginStep.verifyCode;
      if (_emailController.text != email) _emailController.text = email;
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
      if (_validatedEmail != null) _emailController.text = _validatedEmail!;
      else _emailController.clear();
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

  Future<void> _launchUrlRegister() async {
    final Uri url = Uri.parse(AppConfig.registerUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    Widget currentStepWidget;
    switch (_currentStep) {
      case LoginStep.enterEmail:
        currentStepWidget = LoginStep1(
          key: const ValueKey('step1'),
          emailController: _emailController,
          onSuccess: _goToStep2,
          onRegister: _launchUrlRegister,
        );
      case LoginStep.verifyCode:
        currentStepWidget = _validatedEmail == null
            ? const Center(child: CircularProgressIndicator())
            : LoginStep2(key: const ValueKey('step2'), email: _validatedEmail!, onBack: _goToStep1, onResendCode: _goToStep3);
        break;
      case LoginStep.forgetPassword:
        currentStepWidget = LoginStep3(key: const ValueKey('step3'), emailController: _emailController, onSuccess: _goToStep2FromForget, onBack: _goToStep1);
        break;
    }

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: [
          // Background Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.blackColor.withOpacity(0.4), theme.blackColor.withOpacity(0.8)],
                ),
              ),
            ),
          ),

          // Content Layer with SafeArea and Column to fix Version alignment
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image(image: theme.logoImage, height: 120),
                          const SizedBox(height: 48.0),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: currentStepWidget,
                          ),
                          const SizedBox(height: 24.0),
                          TextButton(
                            onPressed: () => _launchUrlRegister(),
                            child: Text('Don\'t have an account? Register', style: TextStyle(color: theme.secondaryColor)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Version Layer (Bottom Center)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    AppConfig.version,
                    style: TextStyle(
                      color: theme.whiteColor.withOpacity(0.4),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// هنا يمكنك وضع كلاسات LoginStep1, LoginStep2, LoginStep3
// (التي شاركتني بها سابقاً) كما هي بدون تغييرات إضافية.
// =======================================================

// =======================================================
// --- STEP 1: Enter Email Only (Login) ---
// =======================================================
class LoginStep1 extends StatefulWidget {
  final TextEditingController emailController;
  final Function(String email) onSuccess;
  final VoidCallback onRegister; // 1. زدنا تعريف المتغير هنا

  const LoginStep1({
    required Key key,
    required this.emailController,
    required this.onSuccess,
    required this.onRegister, // 2. زدناها هنا باش تولي مطلوبة (required)
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

    setState(() {
      _isLoading = true;
    });

    final AuthApiService authService = AuthApiService();
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
        // نمرر الخطأ للدالة الجديدة التي تحتوي على زر التسجيل
        _showErrorDialog(
          result['message'] ?? 'The provided email address is not registered.',
        );
      }
    }
  }

  // دالة الخطأ المعدلة لتكون احترافية
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Not Found'), // عنوان احترافي
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.emailController.clear();
              _emailFocusNode.requestFocus();
            },
            child: const Text('Okay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onRegister(); // استدعاء دالة التسجيل الخارجية
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Provider.of<ThemeProvider>(context, listen: false).currentTheme.secondaryColor,
            ),
            child: const Text('Register Now', style: TextStyle(color: Colors.white)),
          ),
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
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email address';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16.0),
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
              style: TextStyle(fontSize: 18.0, color: theme.whiteColor),
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