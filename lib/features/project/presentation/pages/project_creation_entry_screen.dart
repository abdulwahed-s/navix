import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/project_creation_entry/animated_background.dart';
import '../widgets/project_creation_entry/floating_decorations.dart';
import '../widgets/project_creation_entry/option_card.dart';
import '../widgets/project_creation_entry/page_header.dart';
import '../widgets/project_creation_entry/team_size_card.dart';

class ProjectCreationEntryScreen extends StatefulWidget {
  final List<String> userSkills;

  const ProjectCreationEntryScreen({super.key, required this.userSkills});

  @override
  State<ProjectCreationEntryScreen> createState() =>
      _ProjectCreationEntryScreenState();
}

class _ProjectCreationEntryScreenState extends State<ProjectCreationEntryScreen>
    with TickerProviderStateMixin {
  int _teamSize = 1;

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.createProject,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),
          FloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            screenSize: size,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: l10n.chooseProjectPath,
                    subtitle: l10n.choosePathSubtitle,
                  ),
                  const SizedBox(height: 32),

                  TeamSizeCard(
                    label: l10n.teamSizeLabel,
                    description: l10n.teamSizeDesc,
                    membersLabel: l10n.members,
                    teamSize: _teamSize,
                    onTeamSizeChanged: (value) {
                      setState(() {
                        _teamSize = value;
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  OptionCard(
                    icon: Icons.lightbulb_outline,
                    iconColor: AppColors.accentGold,
                    title: l10n.iHaveAnIdea,
                    description: l10n.iHaveAnIdeaDesc,
                    isDark: isDark,
                    onTap: () {
                      context.push(
                        '/idea-refinement',
                        extra: {
                          'skills': widget.userSkills,
                          'teamSize': _teamSize,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  OptionCard(
                    icon: Icons.psychology_outlined,
                    iconColor: AppColors.accentLavender,
                    title: l10n.iDontHaveIdea,
                    description: l10n.iDontHaveIdeaDesc,
                    isDark: isDark,
                    onTap: () {
                      context.push(
                        AppRoutes.projectIdeas,
                        extra: {
                          'skills': widget.userSkills,
                          'teamSize': _teamSize,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
