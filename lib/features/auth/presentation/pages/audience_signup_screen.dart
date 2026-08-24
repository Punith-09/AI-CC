import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/signup_button.dart';
import '../widgets/signup_dropdown.dart';
import '../widgets/signup_header.dart';
import '../widgets/signup_textfield.dart';


class AudienceSignUpScreen extends StatefulWidget {
  const AudienceSignUpScreen({super.key});

  @override
  State<AudienceSignUpScreen> createState() =>
      _AudienceSignUpScreenState();
}

class _AudienceSignUpScreenState extends State<AudienceSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? _gender;
  String? _country;
  String? _state;
  String? _city;

  // ============================================================
  // COUNTRY -> STATE -> CITY DATA
  // ============================================================

  static const Map<String, List<String>> _statesByCountry = {
    'India': [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Other',
    ],
    'USA': [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
      'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
      'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
      'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
      'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
      'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
      'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
      'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'Other',
    ],
    'UK': [
      'England', 'Scotland', 'Wales', 'Northern Ireland', 'Other',
    ],
  };

  static const Map<String, List<String>> _citiesByState = {
    // India
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Tirupati', 'Kurnool', 'Other'],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Other'],
    'Assam': ['Guwahati', 'Dibrugarh', 'Silchar', 'Other'],
    'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Other'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Other'],
    'Goa': ['Panaji', 'Vasco da Gama', 'Margao', 'Other'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Other'],
    'Haryana': ['Faridabad', 'Gurugram', 'Panipat', 'Ambala', 'Other'],
    'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala', 'Other'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Other'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubli', 'Belagavi', 'Other'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Other'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Other'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Other'],
    'Manipur': ['Imphal', 'Other'],
    'Meghalaya': ['Shillong', 'Other'],
    'Mizoram': ['Aizawl', 'Other'],
    'Nagaland': ['Kohima', 'Dimapur', 'Other'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Other'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Other'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Other'],
    'Sikkim': ['Gangtok', 'Other'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli', 'Other'],
    'Telangana': ['Hyderabad', 'Warangal', 'Khammam', 'Nizamabad', 'Other'],
    'Tripura': ['Agartala', 'Other'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Prayagraj', 'Meerut', 'Other'],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Other'],
    'West Bengal': ['Kolkata', 'Siliguri', 'Asansol', 'Other'],
    // USA
    'California': ['Los Angeles', 'San Francisco', 'San Diego', 'Sacramento', 'Other'],
    'New York': ['New York City', 'Buffalo', 'Rochester', 'Albany', 'Other'],
    'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio', 'Other'],
    'Florida': ['Miami', 'Orlando', 'Tampa', 'Jacksonville', 'Other'],
    'Illinois': ['Chicago', 'Aurora', 'Naperville', 'Other'],
    'Washington': ['Seattle', 'Spokane', 'Tacoma', 'Other'],
    'Georgia': ['Atlanta', 'Augusta', 'Savannah', 'Other'],
    'Pennsylvania': ['Philadelphia', 'Pittsburgh', 'Allentown', 'Other'],
    'North Carolina': ['Charlotte', 'Raleigh', 'Greensboro', 'Other'],
    'Arizona': ['Phoenix', 'Tucson', 'Scottsdale', 'Other'],
    'Massachusetts': ['Boston', 'Worcester', 'Springfield', 'Other'],
    'Tennessee': ['Nashville', 'Memphis', 'Knoxville', 'Other'],
    'Nevada': ['Las Vegas', 'Reno', 'Henderson', 'Other'],
    'Colorado': ['Denver', 'Colorado Springs', 'Aurora', 'Other'],
    'Virginia': ['Virginia Beach', 'Norfolk', 'Chesapeake', 'Richmond', 'Other'],
    'Ohio': ['Columbus', 'Cleveland', 'Cincinnati', 'Other'],
    'Michigan': ['Detroit', 'Grand Rapids', 'Warren', 'Other'],
    'Minnesota': ['Minneapolis', 'Saint Paul', 'Rochester', 'Other'],
    'New Jersey': ['Newark', 'Jersey City', 'Paterson', 'Other'],
    'Indiana': ['Indianapolis', 'Fort Wayne', 'Evansville', 'Other'],
    // UK
    'England': ['London', 'Manchester', 'Birmingham', 'Leeds', 'Liverpool', 'Bristol', 'Other'],
    'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen', 'Other'],
    'Wales': ['Cardiff', 'Swansea', 'Newport', 'Other'],
    'Northern Ireland': ['Belfast', 'Derry', 'Other'],
    'Other': ['Other'],
  };

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F5A6A),
            Color(0xFF123B4A),
            Color(0xFF0B1F2A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            "Audience Sign Up",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              const SignupHeader(
                title: "Audience Registration",
                subtitle: "Complete your audience profile",
                icon: Icons.person,
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123B4A),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Basic Information",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 25),

                          SignupTextField(
                            controller: _fullName,
                            label: "Full Name",
                            requiredField: true,
                          ),

                          SignupTextField(
                            controller: _email,
                            label: "Email",
                            keyboardType: TextInputType.emailAddress,
                            requiredField: true,
                          ),

                          SignupTextField(
                            controller: _phone,
                            label: "Phone Number",
                            keyboardType: TextInputType.phone,
                            requiredField: true,
                          ),

                          SignupDropdown(
                            label: "Gender",
                            items: const [
                              "Male",
                              "Female",
                              "Other",
                            ],
                            value: _gender,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),

                          SignupDropdown(
                            label: "Country",
                            items: const [
                              "India",
                              "USA",
                              "UK",
                            ],
                            value: _country,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _country = value;
                                _state = null;
                                _city = null;
                              });
                            },
                          ),

                          SignupDropdown(
                            label: "State",
                            items: _country != null
                                ? (_statesByCountry[_country!] ?? ['Other'])
                                : ['Select a country first'],
                            value: _state,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _state = value;
                                _city = null;
                              });
                            },
                          ),

                          SignupDropdown(
                            label: "City",
                            items: _state != null
                                ? (_citiesByState[_state!] ?? ['Other'])
                                : ['Select a state first'],
                            value: _city,
                            requiredField: true,
                            onChanged: (value) {
                              setState(() {
                                _city = value;
                              });
                            },
                          ),

                          const SizedBox(height: 30),

                          SignupButton(
                            text: "Create Account",
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Audience account created successfully!",
                                    ),
                                  ),
                                );
                                context.go('/home');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}