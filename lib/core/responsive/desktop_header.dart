import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage.dart';
import '../../common/widgets/user_avatar.dart';
import '../../features/create/presentation/widgets/create_bottom_sheet.dart';
import '../../features/explore/presentation/providers/explore_provider.dart';
import '../../features/messages/presentation/providers/messages_provider.dart';

class DesktopHeader extends StatefulWidget {
  const DesktopHeader({super.key});

  @override
  State<DesktopHeader> createState() => _DesktopHeaderState();
}

class _DesktopHeaderState extends State<DesktopHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    try {
      context.read<ExploreProvider>().onSearchChanged(query.trim());
      context.go(AppRoutes.explore);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserName;
    String? currentUserPic;
    try {
      currentUserName = LocalStorage.instance.getUserName();
      currentUserPic = LocalStorage.instance.getUserProfilePhoto();
    } catch (_) {}

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Brand / Logo ───────────────────────────────────────
          InkWell(
            onTap: () => context.go(AppRoutes.home),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E3CF7).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.clapperboard,
                        color: Color(0xFF4AD0FB),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "AICC",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E3CF7).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "CASTING",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF8E3CF7),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Auditions • Talent • Opportunities",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF64748B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 32),

          // ── Centered Global Search Bar ─────────────────────────
          // Expanded(
          //   child: Center(
          //     child: ConstrainedBox(
          //       constraints: const BoxConstraints(maxWidth: 480),
          //       child: Container(
          //         height: 42,
          //         decoration: BoxDecoration(
          //           color: const Color(0xFFF8FAFC),
          //           borderRadius: BorderRadius.circular(22),
          //           border: Border.all(
          //             color: const Color(0xFFE2E8F0),
          //             width: 1.2,
          //           ),
          //         ),
          //         child: TextField(
          //           controller: _searchController,
          //           textInputAction: TextInputAction.search,
          //           onSubmitted: _onSearchSubmit,
          //           style: GoogleFonts.poppins(
          //             color: const Color(0xFF0F172A),
          //             fontSize: 13.5,
          //           ),
          //           decoration: InputDecoration(
          //             isDense: true,
          //             contentPadding: const EdgeInsets.symmetric(
          //               horizontal: 14,
          //               vertical: 11,
          //             ),
          //             border: InputBorder.none,
          //             enabledBorder: InputBorder.none,
          //             focusedBorder: InputBorder.none,
          //             filled: false,
          //             prefixIcon: const Icon(
          //               LucideIcons.search,
          //               color: Color(0xFF94A3B8),
          //               size: 18,
          //             ),
          //             hintText: "Search for artists, roles, auditions...",
          //             hintStyle: GoogleFonts.poppins(
          //               color: const Color(0xFF94A3B8),
          //               fontSize: 13,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(width: 24),

          // ── Right Action Controls ──────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Post / Create Button
              // InkWell(
              //   onTap: () async {
              //     final route = await showModalBottomSheet<String>(
              //       context: context,
              //       isScrollControlled: true,
              //       backgroundColor: Colors.transparent,
              //       barrierColor: Colors.black.withValues(alpha: 0.65),
              //       builder: (context) => const CreateBottomSheet(),
              //     );
              //     if (route != null && context.mounted) {
              //       context.push(route);
              //     }
              //   },
              //   borderRadius: BorderRadius.circular(20),
              //   child:
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              //     decoration: BoxDecoration(
              //       color: AppColors.buttonPrimary,
              //       borderRadius: BorderRadius.circular(20),
              //       boxShadow: [
              //         BoxShadow(
              //           color: AppColors.buttonPrimary.withValues(alpha: 0.3),
              //           blurRadius: 8,
              //           offset: const Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         const Icon(Icons.add, size: 16, color: Colors.white),
              //         const SizedBox(width: 4),
              //         Text(
              //           "Create",
              //           style: GoogleFonts.poppins(
              //             color: Colors.white,
              //             fontSize: 12.5,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(width: 14),

              // Messages Action with Badge
              // Consumer<MessagesProvider>(
              //   builder: (context, provider, _) {
              //     final unread = provider.totalUnreadCount;
              //     return Stack(
              //       clipBehavior: Clip.none,
              //       children: [
              //         _HeaderIconButton(
              //           icon: LucideIcons.messageSquare,
              //           tooltip: "Messages",
              //           onTap: () => context.go(AppRoutes.messages),
              //         ),
              //         if (unread > 0)
              //           Positioned(
              //             right: 4,
              //             top: 4,
              //             child: Container(
              //               padding: const EdgeInsets.all(3),
              //               decoration: const BoxDecoration(
              //                 color: Color(0xFFEF4444),
              //                 shape: BoxShape.circle,
              //               ),
              //               constraints: const BoxConstraints(
              //                 minWidth: 16,
              //                 minHeight: 16,
              //               ),
              //               child: Center(
              //                 child: Text(
              //                   unread > 9 ? '9+' : '$unread',
              //                   style: const TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 9,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //       ],
              //     );
              //   },
              // ),

              // const SizedBox(width: 8),

              // Notifications Action
              _HeaderIconButton(
                icon: LucideIcons.bell,
                tooltip: "Notifications",
                onTap: () => context.push(AppRoutes.activity),
              ),

              const SizedBox(width: 14),

              // User Profile Avatar Chip
              // InkWell(
              //   onTap: () => context.go(AppRoutes.artistProfile),
              //   borderRadius: BorderRadius.circular(24),
              //   child:
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(
                        imageUrl: currentUserPic,
                        name: currentUserName ?? "User",
                        radius: 14,
                        fontSize: 11,
                        backgroundColor: AppColors.whiteShade,
                      ),
                      if (currentUserName != null && currentUserName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            currentUserName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0F172A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
