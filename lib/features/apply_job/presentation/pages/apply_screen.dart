import 'package:aicc/features/apply_job/presentation/widgets/apply_appbar.dart';
import 'package:aicc/features/apply_job/presentation/widgets/audition_info_card.dart';
import 'package:aicc/features/apply_job/presentation/widgets/cover_letter_field.dart';
import 'package:aicc/features/apply_job/presentation/widgets/gradient_checkbox.dart';
import 'package:aicc/features/apply_job/presentation/widgets/gradient_dropdown.dart';
import 'package:aicc/features/apply_job/presentation/widgets/gradient_text_field.dart';
import 'package:aicc/features/apply_job/presentation/widgets/submit_button.dart';
import 'package:aicc/features/apply_job/presentation/widgets/upload_file_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/app_background.dart';

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

                GradientDropdown(
                  label: "Your Bio Category (Auto-filled)",
                  icon: Icons.person_outline,
                  items: const [
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
                    print("Choose file clicked");
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null) {
                      setState(() {
                        showreelFile = result.files.single.name;
                      });
                    }
                  },
                ),

                const SizedBox(height: 22),

                UploadFileCard(
                  title: "Upload Government ID Card Proof",
                  subtitle: "Passport, Driver's License or PAN Card",
                  fileName: idProofFile,
                  onTap: () async {
                    print("Choose file clicked");
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null) {
                      setState(() {
                        idProofFile = result.files.single.name;
                      });
                    }
                  },
                ),

                const SizedBox(height: 22),

                GradientCheckbox(),

                const SizedBox(height: 30),

                SubmitButton(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
