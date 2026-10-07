// import 'package:aicc/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/routes/app_routes.dart';
// import '../../../../core/theme/theme_provider.dart';
// import '../../data/models/audition_model.dart';
// import '../providers/auditions_provider.dart';
// import '../widgets/bottom_action_bar.dart';
//
// class AuditionDetails extends StatefulWidget {
//   final AuditionModel? audition;
//   final String? auditionId;
//
//   const AuditionDetails({
//     super.key,
//     this.audition,
//     this.auditionId,
//   });
//
//   @override
//   State<AuditionDetails> createState() => _AuditionDetailsState();
// }
//
// class _AuditionDetailsState extends State<AuditionDetails> {
//   static const Color _primaryOrange = Color(0xFFDC8B20);
//   static const Color _cardBg = Color(0xFF1B1B1F);
//   static const Color _labelGrey = Color(0xFF8E8E93);
//   static const Color _bodyGrey = Color(0xFF9E9E9E);
//
//   static final AuditionModel _defaultAudition = const AuditionModel(
//     id: "1",
//     title: "Female Lead - Short Film",
//     category: "Short Film",
//     role: "Acting",
//     language: "Telugu",
//     pay: "₹ 15,000",
//     location: "Hyderabad, Telangana",
//     deadline: "10 Oct 2026",
//     auditionDate: "12 Oct 2026",
//     age: "20 - 28 years",
//     gender: "Female",
//     experience: "0 - 2 years",
//     skills: "Acting, expressions, dialogue delivery",
//     description:
//         "We are looking for a female actor for the lead role in an upcoming short film. Candidates should be comfortable with dialogue delivery and expressive acting.",
//     director: "Pulse Studios",
//     phone: "+91 98765 43210",
//     email: "producer@email.com",
//   );
//
//   static const List<String> _monthNames = [
//     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     final targetId = widget.auditionId ?? widget.audition?.id;
//     if (targetId != null && targetId.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         context.read<AuditionsProvider>().fetchAuditionById(
//               targetId,
//               initialData: widget.audition,
//             );
//       });
//     }
//   }
//
//   // ── Formatters & Derivations ──────────────────────────────────────────────
//
//   String _formatDate(String dateStr) {
//     if (dateStr.isEmpty) return 'N/A';
//     final trimmed = dateStr.trim();
//     try {
//       if (trimmed.contains('-')) {
//         final parts = trimmed.split('-');
//         if (parts.length == 3 && parts[0].length == 4) {
//           final year = int.parse(parts[0]);
//           final month = int.parse(parts[1]);
//           final day = int.parse(parts[2].split('T').first.split(' ').first);
//           if (month >= 1 && month <= 12) {
//             return '$day ${_monthNames[month - 1]} $year';
//           }
//         } else if (parts.length == 3 && parts[2].length == 4) {
//           final day = int.parse(parts[0]);
//           final month = int.parse(parts[1]);
//           final year = int.parse(parts[2].split('T').first.split(' ').first);
//           if (month >= 1 && month <= 12) {
//             return '$day ${_monthNames[month - 1]} $year';
//           }
//         }
//       }
//       final dt = DateTime.tryParse(trimmed);
//       if (dt != null) {
//         return '${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';
//       }
//     } catch (_) {}
//     return trimmed;
//   }
//
//   String _deriveAuditionDate(String auditionDate, String deadline) {
//     if (auditionDate.isNotEmpty) {
//       return _formatDate(auditionDate);
//     }
//     if (deadline.isNotEmpty) {
//       try {
//         final trimmed = deadline.trim();
//         DateTime? dt;
//         if (trimmed.contains('-')) {
//           final parts = trimmed.split('-');
//           if (parts.length == 3 && parts[0].length == 4) {
//             dt = DateTime.tryParse(trimmed.split('T').first);
//           } else if (parts.length == 3 && parts[2].length == 4) {
//             final day = int.parse(parts[0]);
//             final month = int.parse(parts[1]);
//             final year = int.parse(parts[2].split('T').first.split(' ').first);
//             dt = DateTime(year, month, day);
//           }
//         } else {
//           dt = DateTime.tryParse(trimmed);
//         }
//         if (dt != null) {
//           final audDt = dt.add(const Duration(days: 2));
//           return '${audDt.day} ${_monthNames[audDt.month - 1]} ${audDt.year}';
//         }
//       } catch (_) {}
//     }
//     return '12 Oct 2026';
//   }
//
//   String _formatPay(String payStr) {
//     if (payStr.isEmpty) return '₹ 15,000';
//     final trimmed = payStr.trim();
//     if (trimmed.startsWith('₹')) {
//       if (trimmed.length > 1 && trimmed[1] != ' ') {
//         return '₹ ${trimmed.substring(1)}';
//       }
//       return trimmed;
//     }
//     return '₹ $trimmed';
//   }
//
//   String _deriveAge(AuditionModel item) {
//     if (item.age.isNotEmpty) return item.age;
//     final role = item.role;
//     final desc = item.description;
//     final regExp = RegExp(r'(\d{2})\s*[-–]\s*(\d{2})');
//     final match = regExp.firstMatch(role) ?? regExp.firstMatch(desc);
//     if (match != null) {
//       return '${match.group(1)} - ${match.group(2)} years';
//     }
//     return '20 - 28 years';
//   }
//
//   String _deriveGender(AuditionModel item) {
//     if (item.gender.isNotEmpty) return item.gender;
//     final text = '${item.role} ${item.title} ${item.description}'.toLowerCase();
//     if (text.contains('female') || text.contains('actress') || text.contains('woman') || text.contains('girl')) {
//       return 'Female';
//     }
//     if (text.contains('male') || text.contains('actor') || text.contains('man') || text.contains('boy') || text.contains('hero')) {
//       return 'Male';
//     }
//     return 'Female';
//   }
//
//   String _deriveExperience(AuditionModel item) {
//     if (item.experience.isNotEmpty) return item.experience;
//     final text = '${item.role} ${item.description}'.toLowerCase();
//     final regExp = RegExp(r'(\d+)\s*[-–]\s*(\d+)\s*years?');
//     final match = regExp.firstMatch(text);
//     if (match != null) {
//       return '${match.group(1)} - ${match.group(2)} years';
//     }
//     return '0 - 2 years';
//   }
//
//   String _deriveLanguage(AuditionModel item) {
//     if (item.language.isNotEmpty && item.language != 'N/A') {
//       return item.language;
//     }
//     return 'Telugu';
//   }
//
//   String _deriveSkills(AuditionModel item) {
//     if (item.skills.isNotEmpty) return item.skills;
//     if (item.category.toLowerCase().contains('dance')) {
//       return 'Dance, expressions, rhythm';
//     }
//     return 'Acting, expressions, dialogue delivery';
//   }
//
//   String _getDisplayTitle(AuditionModel item) {
//     if (item.title.isNotEmpty) {
//       if (item.category.isNotEmpty &&
//           !item.title.toLowerCase().contains(item.category.toLowerCase()) &&
//           !item.title.contains('-')) {
//         return "${item.title} - ${item.category}";
//       }
//       return item.title;
//     }
//     if (item.role.isNotEmpty && item.category.isNotEmpty) {
//       return "${item.role} - ${item.category}";
//     }
//     return item.role.isNotEmpty ? item.role : "Audition Details";
//   }
//
//   String _getDisplaySubtitle(AuditionModel item) {
//     final category = item.category.isNotEmpty ? item.category : "Short Film";
//     String rolePart = "Acting";
//     if (item.role.isNotEmpty) {
//       final cleanRole = item.role.split('(').first.trim();
//       if (cleanRole.isNotEmpty && cleanRole.toLowerCase() != category.toLowerCase()) {
//         rolePart = cleanRole;
//       }
//     }
//     return "$category  |  $rolePart";
//   }
//
//   // ── UI Components ─────────────────────────────────────────────────────────
//
//   Widget _buildSectionHeader(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 3.5,
//           height: 20,
//           decoration: BoxDecoration(
//             color: _primaryOrange,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             letterSpacing: -0.2,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: 20,
//             color: _primaryOrange,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: _labelGrey,
//               fontSize: 11,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w600,
//               height: 1.25,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return VerticalDivider(
//       color: _primaryOrange.withValues(alpha: 0.35),
//       thickness: 1,
//       width: 1,
//       indent: 6,
//       endIndent: 6,
//     );
//   }
//
//   Widget _buildRequirementRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 115,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: _labelGrey,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 height: 1.3,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildApplicantCard(ApplicantModel applicant) {
//     Color statusColor;
//     switch (applicant.status.toUpperCase()) {
//       case 'APPROVED':
//       case 'ACCEPTED':
//         statusColor = Colors.greenAccent;
//         break;
//       case 'REJECTED':
//         statusColor = Colors.redAccent;
//         break;
//       case 'PENDING':
//       default:
//         statusColor = _primaryOrange;
//         break;
//     }
//
//     final dateStr = applicant.appliedDate.isNotEmpty
//         ? applicant.appliedDate.split('T').first
//         : '';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _cardBg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withValues(alpha: 0.08),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: _primaryOrange.withValues(alpha: 0.2),
//                 child: Text(
//                   applicant.name.isNotEmpty ? applicant.name[0].toUpperCase() : 'A',
//                   style: const TextStyle(
//                     color: _primaryOrange,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       applicant.name.isNotEmpty ? applicant.name : 'Applicant',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (dateStr.isNotEmpty) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         'Applied on $dateStr',
//                         style: const TextStyle(
//                           color: _labelGrey,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               if (applicant.category.isNotEmpty) ...[
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _primaryOrange.withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: _primaryOrange.withValues(alpha: 0.4),
//                     ),
//                   ),
//                   child: Text(
//                     applicant.category,
//                     style: const TextStyle(
//                       color: _primaryOrange,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withValues(alpha: 0.15),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: statusColor.withValues(alpha: 0.6)),
//                 ),
//                 child: Text(
//                   applicant.status,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (applicant.coverLetter.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Cover Letter:",
//                     style: TextStyle(
//                       color: _labelGrey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     applicant.coverLetter,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auditionsProvider = context.watch<AuditionsProvider>();
//     final item = auditionsProvider.selectedAudition ?? widget.audition ?? _defaultAudition;
//     final isLoading = auditionsProvider.isDetailLoading && auditionsProvider.selectedAudition == null;
//     final errorMessage = auditionsProvider.detailErrorMessage;
//
//     final isMyAudition = item.createdByMe ||
//         auditionsProvider.myPostedAuditions.any((a) => a.id == item.id);
//
//     final displayTitle = _getDisplayTitle(item);
//     final displaySubtitle = _getDisplaySubtitle(item);
//     final displayLocation = item.location.isNotEmpty ? item.location : "Hyderabad,\nTelangana";
//     final displayPay = _formatPay(item.pay);
//     final displayDeadline = _formatDate(item.deadline.isNotEmpty ? item.deadline : "10 Oct 2026");
//     final displayAuditionDate = _deriveAuditionDate(item.auditionDate, item.deadline);
//     final displayAge = _deriveAge(item);
//     final displayGender = _deriveGender(item);
//     final displayExperience = _deriveExperience(item);
//     final displayLanguage = _deriveLanguage(item);
//     final displaySkills = _deriveSkills(item);
//     final displayDescription = item.description.isNotEmpty
//         ? item.description
//         : "We are looking for a female actor for the lead role in an upcoming short film. Candidates should be comfortable with dialogue delivery and expressive acting.";
//     final isDark = context.read<ThemeProvider>().isDarkMode;
//     return Scaffold(
//       backgroundColor: isDark?AppColors.black:AppColors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// Sleek Back Button Row
//             Padding(
//               padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       if (Navigator.of(context).canPop()) {
//                         context.pop();
//                       } else {
//                         context.go(AppRoutes.auditions);
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     splashRadius: 20,
//                     tooltip: 'Back',
//                   ),
//                 ],
//               ),
//             ),
//
//             if (isLoading)
//               const Expanded(
//                 child: Center(
//                   child: CircularProgressIndicator(color: _primaryOrange),
//                 ),
//               )
//             else if (errorMessage != null && auditionsProvider.selectedAudition == null)
//               Expanded(
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           errorMessage,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(color: Colors.redAccent, fontSize: 16),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _primaryOrange,
//                             foregroundColor: Colors.white,
//                           ),
//                           onPressed: () {
//                             final targetId = widget.auditionId ?? widget.audition?.id;
//                             if (targetId != null) {
//                               context.read<AuditionsProvider>().fetchAuditionById(targetId);
//                             }
//                           },
//                           child: const Text("Retry"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//
//                       /// Title
//                       Text(
//                         displayTitle,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: -0.3,
//                         ),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       /// Subtitle: Category  |  Role
//                       Text(
//                         displaySubtitle,
//                         style: const TextStyle(
//                           color: _primaryOrange,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//
//                       const SizedBox(height: 22),
//
//                       /// 4-Column Card (Location | Pay | Deadline | Audition Date)
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
//                         decoration: BoxDecoration(
//                           color: _cardBg,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: Colors.white.withValues(alpha: 0.08),
//                             width: 1,
//                           ),
//                         ),
//                         child: IntrinsicHeight(
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: _buildStatItem(
//                                   icon: Icons.location_on_outlined,
//                                   label: "Location",
//                                   value: displayLocation,
//                                 ),
//                               ),
//                               _buildDivider(),
//                               Expanded(
//                                 child: _buildStatItem(
//                                   icon: Icons.currency_rupee,
//                                   label: "Pay",
//                                   value: displayPay,
//                                 ),
//                               ),
//                               _buildDivider(),
//                               Expanded(
//                                 child: _buildStatItem(
//                                   icon: Icons.calendar_today_outlined,
//                                   label: "Deadline",
//                                   value: displayDeadline,
//                                 ),
//                               ),
//                               _buildDivider(),
//                               Expanded(
//                                 child: _buildStatItem(
//                                   icon: Icons.calendar_month_outlined,
//                                   label: "Audition Date",
//                                   value: displayAuditionDate,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 28),
//
//                       /// About the Audition Section
//                       _buildSectionHeader("About the Audition"),
//                       const SizedBox(height: 12),
//                       Text(
//                         displayDescription,
//                         style: const TextStyle(
//                           color: _bodyGrey,
//                           fontSize: 13.5,
//                           height: 1.55,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//
//                       const SizedBox(height: 28),
//
//                       /// Role Requirements Section
//                       _buildSectionHeader("Role Requirements"),
//                       const SizedBox(height: 16),
//                       _buildRequirementRow("Age", displayAge),
//                       _buildRequirementRow("Gender", displayGender),
//                       _buildRequirementRow("Experience", displayExperience),
//                       _buildRequirementRow("Language", displayLanguage),
//                       _buildRequirementRow("Skills", displaySkills),
//
//                       /// Show applicants section if this audition was created by the user or has applicants
//                       if (isMyAudition || item.applicants.isNotEmpty) ...[
//                         const SizedBox(height: 28),
//                         _buildSectionHeader("Applicants (${item.applicantsCount})"),
//                         const SizedBox(height: 14),
//                         if (item.applicants.isEmpty)
//                           const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               "No applicants yet.",
//                               style: TextStyle(
//                                 color: _labelGrey,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           )
//                         else
//                           ...item.applicants.map((a) => _buildApplicantCard(a)),
//                       ],
//
//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ),
//
//             /// Bottom Apply Bar (shown only if not created by me)
//             if (!isMyAudition)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//                 child: BottomActionBar(audition: item),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../data/models/audition_model.dart';
import '../providers/auditions_provider.dart';
import '../widgets/bottom_action_bar.dart';

class AuditionDetails extends StatefulWidget {
  final AuditionModel? audition;
  final String? auditionId;

  const AuditionDetails({
    super.key,
    this.audition,
    this.auditionId,
  });

  @override
  State<AuditionDetails> createState() => _AuditionDetailsState();
}

class _AuditionDetailsState extends State<AuditionDetails> {
  // ---------------------------------------------------------------------------
  // THEME COLORS
  // ---------------------------------------------------------------------------

  static const Color _primaryOrange = Color(0xFFDC8B20);

  bool get _isDark => context.watch<ThemeProvider>().isDarkMode;

  Color get _cardBg {
    return _isDark
        ? const Color(0xFF1B1B1F)
        : const Color(0xFFF5F5F5);
  }

  Color get _primaryText {
    return _isDark
        ? Colors.white
        : const Color(0xFF1B1B1F);
  }

  Color get _secondaryText {
    return _isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF666666);
  }

  Color get _labelGrey {
    return _isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF777777);
  }

  Color get _borderColor {
    return _isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
  }

  Color get _innerCardBg {
    return _isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.04);
  }

  // ---------------------------------------------------------------------------
  // DEFAULT AUDITION
  // ---------------------------------------------------------------------------

  static final AuditionModel _defaultAudition = const AuditionModel(
    id: "1",
    title: "Female Lead - Short Film",
    category: "Short Film",
    role: "Acting",
    language: "Telugu",
    pay: "₹ 15,000",
    location: "Hyderabad, Telangana",
    deadline: "10 Oct 2026",
    auditionDate: "12 Oct 2026",
    age: "20 - 28 years",
    gender: "Female",
    experience: "0 - 2 years",
    skills: "Acting, expressions, dialogue delivery",
    description:
    "We are looking for a female actor for the lead role in an upcoming short film. Candidates should be comfortable with dialogue delivery and expressive acting.",
    director: "Pulse Studios",
    phone: "+91 98765 43210",
    email: "producer@email.com",
  );

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final targetId = widget.auditionId ?? widget.audition?.id;

    if (targetId != null && targetId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuditionsProvider>().fetchAuditionById(
          targetId,
          initialData: widget.audition,
        );
      });
    }
  }

  // ---------------------------------------------------------------------------
  // FORMATTERS & DERIVATIONS
  // ---------------------------------------------------------------------------

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';

    final trimmed = dateStr.trim();

    try {
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');

        if (parts.length == 3 && parts[0].length == 4) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(
            parts[2].split('T').first.split(' ').first,
          );

          if (month >= 1 && month <= 12) {
            return '$day ${_monthNames[month - 1]} $year';
          }
        } else if (parts.length == 3 && parts[2].length == 4) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(
            parts[2].split('T').first.split(' ').first,
          );

          if (month >= 1 && month <= 12) {
            return '$day ${_monthNames[month - 1]} $year';
          }
        }
      }

      final dt = DateTime.tryParse(trimmed);

      if (dt != null) {
        return '${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {}

    return trimmed;
  }

  String _deriveAuditionDate(
      String auditionDate,
      String deadline,
      ) {
    if (auditionDate.isNotEmpty) {
      return _formatDate(auditionDate);
    }

    if (deadline.isNotEmpty) {
      try {
        final trimmed = deadline.trim();

        DateTime? dt;

        if (trimmed.contains('-')) {
          final parts = trimmed.split('-');

          if (parts.length == 3 && parts[0].length == 4) {
            dt = DateTime.tryParse(
              trimmed.split('T').first,
            );
          } else if (parts.length == 3 && parts[2].length == 4) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(
              parts[2].split('T').first.split(' ').first,
            );

            dt = DateTime(year, month, day);
          }
        } else {
          dt = DateTime.tryParse(trimmed);
        }

        if (dt != null) {
          final audDt = dt.add(const Duration(days: 2));

          return '${audDt.day} '
              '${_monthNames[audDt.month - 1]} '
              '${audDt.year}';
        }
      } catch (_) {}
    }

    return '12 Oct 2026';
  }

  String _formatPay(String payStr) {
    if (payStr.isEmpty) return '₹ 15,000';

    final trimmed = payStr.trim();

    if (trimmed.startsWith('₹')) {
      if (trimmed.length > 1 && trimmed[1] != ' ') {
        return '₹ ${trimmed.substring(1)}';
      }

      return trimmed;
    }

    return '₹ $trimmed';
  }

  String _deriveAge(AuditionModel item) {
    if (item.age.isNotEmpty) return item.age;

    final role = item.role;
    final desc = item.description;

    final regExp = RegExp(r'(\d{2})\s*[-–]\s*(\d{2})');

    final match =
        regExp.firstMatch(role) ?? regExp.firstMatch(desc);

    if (match != null) {
      return '${match.group(1)} - ${match.group(2)} years';
    }

    return '20 - 28 years';
  }

  String _deriveGender(AuditionModel item) {
    if (item.gender.isNotEmpty) return item.gender;

    final text =
    '${item.role} ${item.title} ${item.description}'.toLowerCase();

    if (text.contains('female') ||
        text.contains('actress') ||
        text.contains('woman') ||
        text.contains('girl')) {
      return 'Female';
    }

    if (text.contains('male') ||
        text.contains('actor') ||
        text.contains('man') ||
        text.contains('boy') ||
        text.contains('hero')) {
      return 'Male';
    }

    return 'Female';
  }

  String _deriveExperience(AuditionModel item) {
    if (item.experience.isNotEmpty) {
      return item.experience;
    }

    final text =
    '${item.role} ${item.description}'.toLowerCase();

    final regExp = RegExp(
      r'(\d+)\s*[-–]\s*(\d+)\s*years?',
    );

    final match = regExp.firstMatch(text);

    if (match != null) {
      return '${match.group(1)} - ${match.group(2)} years';
    }

    return '0 - 2 years';
  }

  String _deriveLanguage(AuditionModel item) {
    if (item.language.isNotEmpty && item.language != 'N/A') {
      return item.language;
    }

    return 'Telugu';
  }

  String _deriveSkills(AuditionModel item) {
    if (item.skills.isNotEmpty) {
      return item.skills;
    }

    if (item.category.toLowerCase().contains('dance')) {
      return 'Dance, expressions, rhythm';
    }

    return 'Acting, expressions, dialogue delivery';
  }

  String _getDisplayTitle(AuditionModel item) {
    if (item.title.isNotEmpty) {
      if (item.category.isNotEmpty &&
          !item.title
              .toLowerCase()
              .contains(item.category.toLowerCase()) &&
          !item.title.contains('-')) {
        return "${item.title} - ${item.category}";
      }

      return item.title;
    }

    if (item.role.isNotEmpty && item.category.isNotEmpty) {
      return "${item.role} - ${item.category}";
    }

    return item.role.isNotEmpty
        ? item.role
        : "Audition Details";
  }

  String _getDisplaySubtitle(AuditionModel item) {
    final category =
    item.category.isNotEmpty ? item.category : "Short Film";

    String rolePart = "Acting";

    if (item.role.isNotEmpty) {
      final cleanRole = item.role.split('(').first.trim();

      if (cleanRole.isNotEmpty &&
          cleanRole.toLowerCase() != category.toLowerCase()) {
        rolePart = cleanRole;
      }
    }

    return "$category  |  $rolePart";
  }

  // ---------------------------------------------------------------------------
  // UI COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 20,
          decoration: BoxDecoration(
            color: _primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: _primaryOrange,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _labelGrey,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return VerticalDivider(
      color: _primaryOrange.withValues(alpha: 0.35),
      thickness: 1,
      width: 1,
      indent: 6,
      endIndent: 6,
    );
  }

  Widget _buildRequirementRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(
                color: _labelGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(
      ApplicantModel applicant,
      ) {
    Color statusColor;

    switch (applicant.status.toUpperCase()) {
      case 'APPROVED':
      case 'ACCEPTED':
        statusColor = Colors.greenAccent;
        break;

      case 'REJECTED':
        statusColor = Colors.redAccent;
        break;

      case 'PENDING':
      default:
        statusColor = _primaryOrange;
        break;
    }

    final dateStr = applicant.appliedDate.isNotEmpty
        ? applicant.appliedDate.split('T').first
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                _primaryOrange.withValues(alpha: 0.2),
                child: Text(
                  applicant.name.isNotEmpty
                      ? applicant.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: _primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name.isNotEmpty
                          ? applicant.name
                          : 'Applicant',
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Applied on $dateStr',
                        style: TextStyle(
                          color: _labelGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (applicant.category.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                    _primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _primaryOrange.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Text(
                    applicant.category,
                    style: const TextStyle(
                      color: _primaryOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                  statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    statusColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  applicant.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (applicant.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _innerCardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cover Letter:",
                    style: TextStyle(
                      color: _labelGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.coverLetter,
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final auditionsProvider =
    context.watch<AuditionsProvider>();

    final item = auditionsProvider.selectedAudition ??
        widget.audition ??
        _defaultAudition;

    final isLoading =
        auditionsProvider.isDetailLoading &&
            auditionsProvider.selectedAudition == null;

    final errorMessage =
        auditionsProvider.detailErrorMessage;

    final isMyAudition = item.createdByMe ||
        auditionsProvider.myPostedAuditions
            .any((a) => a.id == item.id);

    final displayTitle = _getDisplayTitle(item);

    final displaySubtitle =
    _getDisplaySubtitle(item);

    final displayLocation = item.location.isNotEmpty
        ? item.location
        : "Hyderabad,\nTelangana";

    final displayPay = _formatPay(item.pay);

    final displayDeadline = _formatDate(
      item.deadline.isNotEmpty
          ? item.deadline
          : "10 Oct 2026",
    );

    final displayAuditionDate =
    _deriveAuditionDate(
      item.auditionDate,
      item.deadline,
    );

    final displayAge = _deriveAge(item);

    final displayGender = _deriveGender(item);

    final displayExperience =
    _deriveExperience(item);

    final displayLanguage =
    _deriveLanguage(item);

    final displaySkills =
    _deriveSkills(item);

    final displayDescription =
    item.description.isNotEmpty
        ? item.description
        : "We are looking for a female actor for the lead role in an upcoming short film. Candidates should be comfortable with dialogue delivery and expressive acting.";

    return Scaffold(
      backgroundColor:
      _isDark ? AppColors.black : AppColors.white,

      body: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // BACK BUTTON
            // -----------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                top: 4,
                bottom: 4,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go(
                          AppRoutes.auditions,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _primaryText,
                      size: 20,
                    ),
                    splashRadius: 20,
                    tooltip: 'Back',
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // LOADING
            // -----------------------------------------------------------------

            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: _primaryOrange,
                  ),
                ),
              )

            // -----------------------------------------------------------------
            // ERROR
            // -----------------------------------------------------------------

            else if (errorMessage != null &&
                auditionsProvider.selectedAudition == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            _primaryOrange,
                            foregroundColor:
                            Colors.white,
                          ),
                          onPressed: () {
                            final targetId =
                                widget.auditionId ??
                                    widget.audition?.id;

                            if (targetId != null) {
                              context
                                  .read<
                                  AuditionsProvider>()
                                  .fetchAuditionById(
                                targetId,
                              );
                            }
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
              )

            // -----------------------------------------------------------------
            // MAIN CONTENT
            // -----------------------------------------------------------------

            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // -------------------------------------------------------
                      // TITLE
                      // -------------------------------------------------------

                      Text(
                        displayTitle,
                        style: TextStyle(
                          color: _primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // -------------------------------------------------------
                      // SUBTITLE
                      // -------------------------------------------------------

                      Text(
                        displaySubtitle,
                        style: const TextStyle(
                          color: _primaryOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // -------------------------------------------------------
                      // 4 COLUMN STAT CARD
                      // -------------------------------------------------------

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: _borderColor,
                            width: 1,
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons
                                      .location_on_outlined,
                                  label: "Location",
                                  value:
                                  displayLocation,
                                ),
                              ),

                              _buildDivider(),

                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons
                                      .currency_rupee,
                                  label: "Pay",
                                  value: displayPay,
                                ),
                              ),

                              _buildDivider(),

                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons
                                      .calendar_today_outlined,
                                  label: "Deadline",
                                  value:
                                  displayDeadline,
                                ),
                              ),

                              _buildDivider(),

                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons
                                      .calendar_month_outlined,
                                  label: "Audition Date",
                                  value:
                                  displayAuditionDate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // -------------------------------------------------------
                      // ABOUT AUDITION
                      // -------------------------------------------------------

                      _buildSectionHeader(
                        "About the Audition",
                      ),

                      const SizedBox(height: 12),

                      Text(
                        displayDescription,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // -------------------------------------------------------
                      // ROLE REQUIREMENTS
                      // -------------------------------------------------------

                      _buildSectionHeader(
                        "Role Requirements",
                      ),

                      const SizedBox(height: 16),

                      _buildRequirementRow(
                        "Age",
                        displayAge,
                      ),

                      _buildRequirementRow(
                        "Gender",
                        displayGender,
                      ),

                      _buildRequirementRow(
                        "Experience",
                        displayExperience,
                      ),

                      _buildRequirementRow(
                        "Language",
                        displayLanguage,
                      ),

                      _buildRequirementRow(
                        "Skills",
                        displaySkills,
                      ),

                      // -------------------------------------------------------
                      // APPLICANTS
                      // -------------------------------------------------------

                      if (isMyAudition ||
                          item.applicants.isNotEmpty) ...[
                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          "Applicants (${item.applicantsCount})",
                        ),

                        const SizedBox(height: 14),

                        if (item.applicants.isEmpty)
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Text(
                              "No applicants yet.",
                              style: TextStyle(
                                color: _labelGrey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ...item.applicants.map(
                                (a) =>
                                _buildApplicantCard(a),
                          ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

            // -----------------------------------------------------------------
            // BOTTOM APPLY BAR
            // -----------------------------------------------------------------

            if (!isMyAudition)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: BottomActionBar(
                  audition: item,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
