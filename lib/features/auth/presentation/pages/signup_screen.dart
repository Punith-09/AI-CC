import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../../data/models/register_request.dart';

// ── Validation helpers ────────────────────────────────────────────────────────
bool _isValidEmail(String email) {
  // Only @gmail.com addresses are accepted
  final cleanEmail = email.trim().toLowerCase();
  if (!cleanEmail.endsWith('@gmail.com')) {
    return false;
  }
  
  // Ensure the portion before @gmail.com is not empty
  final prefix = cleanEmail.substring(0, cleanEmail.length - 10);
  if (prefix.isEmpty) {
    return false;
  }

  // Ensure prefix contains valid characters
  final prefixRegex = RegExp(r'^[a-z0-9._%+-]+$');
  return prefixRegex.hasMatch(prefix);
}

bool _isValidMobile(String mobile) {
  final mobileRegex = RegExp(r'^[0-9]{10}$');
  return mobileRegex.hasMatch(mobile);
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _selectedRole;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  bool _agreedToTerms = false;
  bool _isPasswordVisible = false;

  final greyColor = const Color(0xFF9E9E9E);
  final borderGrey = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // ── Required field check ──────────────────────────────────────────────────
    if (_selectedRole == null ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    // ── Email validation ──────────────────────────────────────────────────────
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Gmail address (e.g. example@gmail.com)'),
        ),
      );
      return;
    }

    // ── Mobile validation ─────────────────────────────────────────────────────
    final mobile = _mobileController.text.trim();
    if (!_isValidMobile(mobile)) {
      String mobileError;
      if (mobile.contains(RegExp(r'[a-zA-Z]'))) {
        mobileError = 'Mobile number must contain digits only';
      } else if (mobile.length < 10) {
        mobileError = 'Mobile number must be exactly 10 digits';
      } else {
        mobileError = 'Mobile number must be exactly 10 digits';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mobileError)),
      );
      return;
    }

    // ── Terms check ───────────────────────────────────────────────────────────
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms of Service'),
        ),
      );
      return;
    }

    final request = RegisterRequest(
      username: _usernameController.text.trim(),
      email: email,
      password: _passwordController.text,
      role: _selectedRole!.toLowerCase(),
      mobile: mobile,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender!,
    );

    final success = await context.read<AuthProvider>().register(request);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
        ),
      );
      context.go(AppRoutes.home);
    } else {
      final errorMsg = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? 'Registration failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.welcome);
              }
            },
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ----------------------------------------------------
                            // LOGO
                            // ----------------------------------------------------
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 107,
                                    height: 101,
                                    child: Image.asset(
                                      'assets/images/treekologo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  SizedBox(
                                    width: 171,
                                    height: 55,
                                    child: Image.asset(
                                      'assets/images/TreeKo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ----------------------------------------------------
                            // TITLE: CREATE YOUR ACCOUNT
                            // ----------------------------------------------------
                            Text(
                              'CREATE YOUR ACCOUNT',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sora(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ----------------------------------------------------
                            // FORM FIELDS
                            // ----------------------------------------------------
                            _buildDropdown(
                              label: 'Register As',
                              hint: 'Select Role',
                              value: _selectedRole,
                              items: const ['Audience', 'Artist'],
                              onChanged: (val) {
                                setState(() {
                                  _selectedRole = val;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              hint: 'Username',
                              controller: _usernameController,
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              hint: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              hint: 'Create Password',
                              controller: _passwordController,
                              isPassword: true,
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              hint: 'Mobile Number',
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _buildTextField(
                              hint: 'Age',
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),

                            _buildDropdown(
                              hint: 'Gender',
                              value: _selectedGender,
                              items: const ['Male', 'Female', 'Other'],
                              onChanged: (val) {
                                setState(() {
                                  _selectedGender = val;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            // ----------------------------------------------------
                            // TERMS & CONDITIONS
                            // ----------------------------------------------------
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    activeColor: AppColors.primary,
                                    checkColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(color: AppColors.black),
                                    onChanged: (val) {
                                      setState(() {
                                        _agreedToTerms = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I Agree to the ',
                                      style: GoogleFonts.sora(
                                        color: AppColors.black,
                                        fontSize: 12,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms Of Service',
                                          style: GoogleFonts.sora(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' And ',
                                          style: TextStyle(color: AppColors.black),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: GoogleFonts.sora(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // ----------------------------------------------------
                            // SIGN UP BUTTON
                            // ----------------------------------------------------
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return OutlinedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _handleSignup,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.white,
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Sign Up',
                                            style: GoogleFonts.sora(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ----------------------------------------------------
                            // LOGIN LINK
                            // ----------------------------------------------------
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.login);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.black.withValues(alpha: 0.75),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        // hide the counter label that maxLength shows by default
        counterText: '',
        hintStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.hint,
          // backgroundColor: AppColors.black,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 18,
                ),
                splashRadius: 18,
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.hint,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.hint,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    String? label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.hint, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: const Color(0xFF1E1E1E),
              hint: Text(
                hint,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.hint,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.black,
                size: 20,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
