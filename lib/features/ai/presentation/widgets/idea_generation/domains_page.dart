import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'domain_chip.dart';
import 'question_page.dart';

class IdeaDomainsPage extends StatelessWidget {
  final List<String> domainOptions;
  final List<String> selectedDomains;
  final void Function(String domain) onDomainToggle;
  final bool isDark;

  const IdeaDomainsPage({
    super.key,
    required this.domainOptions,
    required this.selectedDomains,
    required this.onDomainToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IdeaQuestionPage(
      title: l10n.projectDomain,
      subtitle: l10n.projectDomainDesc,
      icon: Icons.category_rounded,
      iconColor: AppColors.accentGold,
      isDark: isDark,
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: domainOptions.map((domain) {
          return IdeaDomainChip(
            domain: domain,
            isSelected: selectedDomains.contains(domain),
            onTap: () => onDomainToggle(domain),
            isDark: isDark,
          );
        }).toList(),
      ),
    );
  }
}
