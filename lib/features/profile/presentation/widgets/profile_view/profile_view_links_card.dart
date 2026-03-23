import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileViewLinksCard extends StatelessWidget {
  final String? portfolioLink;

  final String? githubLink;

  final List<String> otherLinks;

  final bool isDark;

  final void Function(String url) onLinkTap;

  const ProfileViewLinksCard({
    super.key,
    required this.portfolioLink,
    required this.githubLink,
    required this.otherLinks,
    required this.isDark,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.brandPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              if (portfolioLink != null)
                _LinkTile(
                  icon: Icons.web_rounded,
                  label: 'Portfolio',
                  url: portfolioLink!,
                  color: AppColors.accentLavender,
                  isDark: isDark,
                  onTap: () => onLinkTap(portfolioLink!),
                ),
              if (githubLink != null)
                _LinkTile(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  url: githubLink!,
                  color: AppColors.brandPrimaryDark,
                  isDark: isDark,
                  onTap: () => onLinkTap(githubLink!),
                ),
              ...otherLinks.map(
                (link) => _LinkTile(
                  icon: Icons.link_rounded,
                  label: _getDomain(link),
                  url: link,
                  color: AppColors.accentMint,
                  isDark: isDark,
                  onTap: () => onLinkTap(link),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
