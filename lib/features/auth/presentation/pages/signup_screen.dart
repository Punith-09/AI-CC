import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../../data/models/register_request.dart';

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

  final primaryBrown = const Color(0xFF8B5E34);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 107,
                    height: 101,
                    child: Image.asset(
                      'assets/icons/aicc3.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: 171,
                    height: 55,
                    child: Image.asset(
                      'assets/icons/text.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'CREATE YOUR ACCOUNT',
                style: GoogleFonts.sora(
                  color: primaryBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),

              // Form
              _buildDropdown(
                label: 'Register As',
                hint: 'Select Role',
                value: _selectedRole,
                items: ['Audience', 'Artist'],
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
                obscureText: true,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                hint: 'Mobile Number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
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
                items: ['Male', 'Female', 'Other'],
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Terms & Conditions
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: primaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: greyColor),
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
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms Of Service',
                            style: GoogleFonts.sora(
                              color: const Color(0xFFD6A054), // golden color similar to text
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' And '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.sora(
                              color: const Color(0xFFD6A054),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return OutlinedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_selectedRole == null ||
                                  _usernameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty ||
                                  _mobileController.text.isEmpty ||
                                  _ageController.text.isEmpty ||
                                  _selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              
                              if (!_agreedToTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('You must agree to the Terms of Service')),
                                );
                                return;
                              }

                              final request = RegisterRequest(
                                username: _usernameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                role: _selectedRole!.toLowerCase(),
                                mobile: _mobileController.text.trim(),
                                age: int.tryParse(_ageController.text.trim()) ?? 0,
                                gender: _selectedGender!,
                                // You can send other static fields here if needed based on API requirements, or leave them null.
                              );

                              final success = await authProvider.register(request);

                              if (!mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registration successful')),
                                );
                                context.go(AppRoutes.home);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage ?? 'Registration failed'),
                                  ),
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBrown,
                        side: BorderSide(color: primaryBrown, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26), // highly rounded like the image
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  }
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.sora(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.sora(
            fontSize: 14,
            color: greyColor,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
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
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.sora(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderGrey, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hint,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  color: greyColor,
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.black87,
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
