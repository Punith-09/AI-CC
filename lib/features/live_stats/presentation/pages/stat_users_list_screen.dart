import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../explore/data/models/talent_model.dart';
import '../../../explore/data/repository/explore_repository.dart';
import '../../../explore/presentation/widgets/talent_card.dart';

// ─── Filter Type Enum ─────────────────────────────────────────────────────────

enum StatFilterType {
  all,       // All registered users
  role,      // artist | audience  (sent directly to backend as ?role=)
  craft,     // Users by craft (sent as ?category=)
  state,     // Users by state (sent as ?location=)
  gender,    // male | female | other/unspecified (client-side)
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class StatUsersListScreen extends StatefulWidget {
  final String title;
  final StatFilterType filterType;
  final String filterValue; // role name, craft name, state name, or gender value
  /// Expected count shown on the stat card — displayed in the subtitle
  final int? expectedCount;

  const StatUsersListScreen({
    super.key,
    required this.title,
    required this.filterType,
    this.filterValue = '',
    this.expectedCount,
  });

  @override
  State<StatUsersListScreen> createState() => _StatUsersListScreenState();
}

class _StatUsersListScreenState extends State<StatUsersListScreen> {
  bool _isLoading = true;
  String? _error;
  List<TalentModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = sl<ExploreRepository>();

      // Build server-side params
      String? category;
      String? location;
      String? role;
      String? gender;

      switch (widget.filterType) {
        case StatFilterType.craft:
          category = widget.filterValue;
          break;
        case StatFilterType.state:
          location = widget.filterValue;
          break;
        case StatFilterType.role:
          // Send the role directly to the backend (artist / audience)
          role = widget.filterValue.toLowerCase();
          break;
        case StatFilterType.gender:
          // For male/female send to backend too so it pre-filters
          final g = widget.filterValue.toLowerCase();
          if (g == 'male' || g == 'female') {
            gender = g;
          }
          break;
        case StatFilterType.all:
          break;
      }

      // Always pass a high limit so we get all matching users, not just the
      // first page (backend may default to 20 or 50 per page).
      final results = await repo.getExploreUsers(
        category: category,
        location: location,
        role: role,
        gender: gender,
        limit: 1000,
      );

      // Exclude the current logged-in user
      String? currentUserId;
      try {
        currentUserId = LocalStorage.instance.getUserId();
      } catch (_) {}

      var filtered = results.where((t) {
        if (currentUserId != null &&
            currentUserId.isNotEmpty &&
            t.id == currentUserId) return false;
        return true;
      }).toList();

      // Additional client-side filtering where backend may not support the param
      switch (widget.filterType) {
        case StatFilterType.gender:
          final genderKey = widget.filterValue.toLowerCase();
          if (genderKey == 'other/unspecified') {
            // Keep only those whose gender is NOT male and NOT female
            filtered = filtered.where((t) {
              final g = t.gender.toLowerCase().trim();
              return g != 'male' &&
                  g != 'm' &&
                  g != 'man' &&
                  g != 'female' &&
                  g != 'f' &&
                  g != 'woman';
            }).toList();
          } else if (genderKey == 'male' || genderKey == 'female') {
            // Backend may have filtered but do a client-side safety pass
            filtered = filtered.where((t) {
              return t.matchesGender(genderKey);
            }).toList();
          }
          break;

        case StatFilterType.role:
          // If the backend ignored the role param fallback to client-side
          final roleKey = widget.filterValue.toLowerCase();
          if (filtered.length == results.length) {
            // backend likely returned everything – apply client filter
            filtered = filtered.where((t) {
              final r = t.role.toLowerCase();
              final c = t.category.toLowerCase();
              if (roleKey == 'artist') {
                return r == 'artist' ||
                    c == 'artist' ||
                    (r.isNotEmpty && r != 'audience' && r != 'guest') ||
                    (c.isNotEmpty && c != 'audience' && c != 'guest');
              } else {
                return r == 'audience' ||
                    r == 'guest' ||
                    c == 'audience' ||
                    c == 'guest';
              }
            }).toList();
          }
          break;

        case StatFilterType.all:
        case StatFilterType.craft:
        case StatFilterType.state:
          break;
      }

      if (mounted) {
        setState(() {
          _users = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkScaffold : const Color(0xFFF4F6FA);
    final titleColor = isDark ? Colors.white : AppColors.lightText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkScaffold : Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black12,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: titleColor,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.sora(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!_isLoading)
                Text(
                  _isLoading
                      ? ''
                      : '${_users.length} profile${_users.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7C3AED),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: titleColor, size: 22),
              onPressed: _isLoading ? null : _fetchUsers,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7C3AED),
          strokeWidth: 2.5,
        ),
      );
    }

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        isDark: isDark,
        onRetry: _fetchUsers,
      );
    }

    if (_users.isEmpty) {
      return _EmptyView(isDark: isDark, title: widget.title);
    }

    return RefreshIndicator(
      color: const Color(0xFF7C3AED),
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return TalentCard(talent: _users[index]);
        },
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool isDark;
  final String title;

  const _EmptyView({required this.isDark, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 60,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No profiles match the "$title" filter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? Colors.white60
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load users',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? Colors.white60
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.sora(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
