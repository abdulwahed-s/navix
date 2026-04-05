import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/find_projects_bloc.dart';
import '../widgets/apply_to_project_dialog.dart';
import '../widgets/project_listing_card.dart';

class FindProjectsScreen extends StatefulWidget {
  const FindProjectsScreen({super.key});

  @override
  State<FindProjectsScreen> createState() => _FindProjectsScreenState();
}

class _FindProjectsScreenState extends State<FindProjectsScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    context.read<FindProjectsBloc>().add(const LoadProjectListings());
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.findProjects,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1A1A2E),
                              const Color(0xFF16213E),
                              const Color(0xFF0F3460),
                            ]
                          : [
                              AppColors.brandCream,
                              Colors.white,
                              AppColors.accentMint.withValues(alpha: 0.15),
                            ],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: -60,
            right: -40,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, _) => Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: BlocConsumer<FindProjectsBloc, FindProjectsState>(
              listener: (context, state) {
                if (state is ApplicationSubmitted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.applicationSent)));

                  context.read<FindProjectsBloc>().add(
                    const LoadProjectListings(),
                  );
                } else if (state is ListingPublished) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Listing published')));

                  context.read<FindProjectsBloc>().add(
                    const LoadProjectListings(),
                  );
                } else if (state is FindProjectsError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is FindProjectsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FindProjectsLoaded) {
                  if (state.listings.isEmpty) {
                    return _buildEmptyState(theme, l10n, isDark);
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<FindProjectsBloc>().add(
                        const LoadProjectListings(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount: state.listings.length,
                      itemBuilder: (context, index) {
                        final listing = state.listings[index];
                        return ProjectListingCard(
                          listing: listing,
                          onApplied: () async {
                            final result = await ApplyToProjectDialog.show(
                              context,
                              openRoles: listing.openRoles,
                              projectName: listing.projectName,
                            );

                            if (result != null && context.mounted) {
                              context.read<FindProjectsBloc>().add(
                                ApplyToProject(
                                  listingId: listing.id,
                                  projectId: listing.projectId,
                                  leaderId: listing.leaderId,
                                  roleName: result['roleName'] as String,
                                  message: result['message'],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    AppColors.accentGold.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outline_rounded,
                size: 56,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noListingsFound,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noListingsFoundSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
