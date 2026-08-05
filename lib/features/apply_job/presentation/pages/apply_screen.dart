import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/app_background.dart';
import '../widgets/apply_appbar.dart';
import '../widgets/audition_info_card.dart';
import '../widgets/cover_letter_field.dart';
import '../widgets/gradient_checkbox.dart';
import '../widgets/gradient_dropdown.dart';
import '../widgets/gradient_text_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/upload_file_card.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  String? showreelFile;
  String? idProofFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const ApplyAppBar(),
                const SizedBox(height: 25),
                const AuditionInfoCard(),
                const SizedBox(height: 30),
                const GradientTextField(
                  label: "Your Full Name (Auto-filled)",
                  hint: "Audrey Hepburn",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 22),
                const GradientDropdown(
                  label: "Your Bio Category (Auto-filled)",
                  icon: Icons.person_outline,
                  items: [
                    "Actor",
                    "Model",
                    "Singer",
                    "Dancer",
                    "Voice Artist",
                  ],
                ),
                const SizedBox(height: 22),
                const CoverLetterField(),
                const SizedBox(height: 22),
                UploadFileCard(
                  title: "Upload Audition Tape/Showreel",
                  subtitle: "Max file size: 100MB",
                  fileName: showreelFile,
                  onTap: () async {
                    try {
                      final FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null && mounted) {
                        setState(() {
                          showreelFile = result.files.single.name;
                        });
                      }
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 22),
                UploadFileCard(
                  title: "Upload Government ID Card Proof",
                  subtitle: "Passport, Driver's License or PAN Card",
                  fileName: idProofFile,
                  onTap: () async {
                    try {
                      final FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null && mounted) {
                        setState(() {
                          idProofFile = result.files.single.name;
                        });
                      }
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 22),
                const GradientCheckbox(),
                const SizedBox(height: 30),
                const SubmitButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
