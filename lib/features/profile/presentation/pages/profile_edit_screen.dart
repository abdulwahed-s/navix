import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/skill_test_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/skill_level.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/skill_bloc.dart';
import '../widgets/profile_edit/profile_edit_animated_background.dart';
import '../widgets/profile_edit/profile_edit_floating_decorations.dart';
import '../widgets/profile_edit/profile_edit_form_field.dart';
import '../widgets/profile_edit/profile_edit_image_picker_sheet.dart';
import '../widgets/profile_edit/profile_edit_loading_overlay.dart';
import '../widgets/profile_edit/profile_edit_other_links_section.dart';
import '../widgets/profile_edit/profile_edit_picture_section.dart';
import '../widgets/profile_edit/profile_edit_save_button.dart';
import '../widgets/profile_edit/profile_edit_skills_dialog.dart';
import '../widgets/profile_edit/profile_edit_skills_section.dart';

const List<String> _predefinedSkills = [
  'Flutter',
  'Dart',
  'Firebase',
  'React',
  'React Native',
  'JavaScript',
  'TypeScript',
  'Python',
  'Java',
  'Kotlin',
  'Swift',
  'iOS',
  'Android',
  'Node.js',
  'Go',
  'Rust',
  'C++',
  'C#',
  'UI/UX Design',
  'Figma',
  'Product Management',
  'Machine Learning',
  'DevOps',
  'AWS',
  'GCP',
  'Azure',
];

class ProfileEditScreen extends StatefulWidget {
  final String userId;
  final ProfileEntity? existingProfile;

  const ProfileEditScreen({
    super.key,
    required this.userId,
    this.existingProfile,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _githubController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _organizationFocusNode = FocusNode();
  final _portfolioFocusNode = FocusNode();
  final _githubFocusNode = FocusNode();

  List<SkillEntity> _selectedSkills = [];
  final List<TextEditingController> _otherLinksControllers = [];
  File? _selectedImageFile;

  String? _existingImageUrl;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  bool get _isNewProfile => widget.existingProfile == null;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.existingProfile != null) {
      _populateExistingData(widget.existingProfile!);
    }
    _nameFocusNode.addListener(() => setState(() {}));
    _organizationFocusNode.addListener(() => setState(() {}));
    _portfolioFocusNode.addListener(() => setState(() {}));
    _githubFocusNode.addListener(() => setState(() {}));
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _populateExistingData(ProfileEntity profile) {
    _nameController.text = profile.name;
    _organizationController.text = profile.organization ?? '';
    _portfolioController.text = profile.portfolioLink ?? '';
    _githubController.text = profile.githubLink ?? '';
    _selectedSkills = List.from(profile.skills);
    _existingImageUrl = profile.profilePicUrl;

    for (final link in profile.otherLinks) {
      _otherLinksControllers.add(TextEditingController(text: link));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _nameFocusNode.dispose();
    _organizationFocusNode.dispose();
    _portfolioFocusNode.dispose();
    _githubFocusNode.dispose();
    _floatingController.dispose();
    for (final controller in _otherLinksControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditImagePickerSheet(
        isDark: isDark,
        takePhotoLabel: l10n.takePhoto,
        galleryLabel: l10n.chooseFromGallery,
        removePhotoLabel:
            (_existingImageUrl != null || _selectedImageFile != null)
            ? l10n.removePhoto
            : null,
        onTakePhoto: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onChooseGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onRemovePhoto: (_existingImageUrl != null || _selectedImageFile != null)
            ? () {
                Navigator.pop(context);
                setState(() {
                  _selectedImageFile = null;
                  _existingImageUrl = null;
                });
              }
            : null,
      ),
    );
  }

  void _showSkillsDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => sl<SkillBloc>(),
        child: ProfileEditSkillsDialog(
          selectedSkills: _selectedSkills,
          predefinedSkills: _predefinedSkills,
          dialogTitle: l10n.selectSkills,
          customSkillHint: l10n.addCustomSkill,
          doneButtonLabel: l10n.done,
          isDark: isDark,
          onSkillsChanged: (skills) {
            setState(() {
              _selectedSkills = skills;
            });
          },
        ),
      ),
    );
  }

  void _showVerifySkillsPrompt(List<SkillEntity> unverifiedSkills) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.quiz_rounded, color: AppColors.accentGold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.verifyYourSkills,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${unverifiedSkills.length} unverified skill${unverifiedSkills.length > 1 ? 's' : ''}. '
              'Take a quick test to verify your proficiency and improve your profile.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: unverifiedSkills.take(5).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill.skillName,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (unverifiedSkills.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${unverifiedSkills.length - 5} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Skipping skill verification');
              Navigator.pop(dialogContext);
              if (mounted) context.go(AppRoutes.home);
            },
            child: Text(l10n.skipStep),
          ),
          FilledButton.icon(
            onPressed: () {
              print('Starting skill verification');
              Navigator.pop(dialogContext);

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                print('Navigating to skill test');
                if (!mounted) return;
                print('Navigating to skill test 2');

                final result = await context.push<SkillTestResult>(
                  AppRoutes.skillTest,
                  extra: unverifiedSkills.map((s) => s.skillName).toList(),
                );
                print('Navigating to skill test 3');
                if (result != null && mounted) {
                  _updateSkillsFromTestResult(result, unverifiedSkills);
                } else {
                  if (mounted) context.go(AppRoutes.home);
                }
              });
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: Text(l10n.verifyNow),
          ),
        ],
      ),
    );
  }

  void _updateSkillsFromTestResult(
    SkillTestResult result,
    List<SkillEntity> testedSkills,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final updatedSkills = _selectedSkills.map((skill) {
      final skillName = skill.skillName;
      final wasTested = testedSkills.any((s) => s.skillName == skillName);

      if (!wasTested) return skill;

      final passed = result.passedSkills[skillName] ?? false;
      final levelString = result.skillLevels[skillName];

      if (passed && levelString != null) {
        return skill.copyWith(
          isVerified: true,
          skillLevel: SkillLevel.fromString(levelString),
        );
      }
      return skill;
    }).toList();

    setState(() {
      _selectedSkills = updatedSkills;
    });

    final existingProfile = widget.existingProfile;
    final profile = ProfileEntity(
      userId: existingProfile?.userId ?? '',
      name: _nameController.text.trim(),
      organization: _organizationController.text.trim().isNotEmpty
          ? _organizationController.text.trim()
          : null,
      profilePicUrl: _existingImageUrl,
      skills: updatedSkills,
      portfolioLink: _portfolioController.text.trim().isNotEmpty
          ? _portfolioController.text.trim()
          : null,
      githubLink: _githubController.text.trim().isNotEmpty
          ? _githubController.text.trim()
          : null,
      otherLinks: _otherLinksControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      createdAt: existingProfile?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<ProfileBloc>().add(
      SaveProfile(profile: profile, isNew: existingProfile == null),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.skillsVerifiedAndSaved),
          ],
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    sl<AuthBloc>().add(const CheckAuthStatusRequested());

    context.go(AppRoutes.home);
  }

  void _addOtherLink() {
    setState(() {
      _otherLinksControllers.add(TextEditingController());
    });
  }

  void _removeOtherLink(int index) {
    setState(() {
      _otherLinksControllers[index].dispose();
      _otherLinksControllers.removeAt(index);
    });
  }

  void _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bloc = context.read<ProfileBloc>();

    if (_selectedImageFile != null) {
      bloc.add(
        UploadProfilePicture(
          userId: widget.userId,
          imageFile: _selectedImageFile!,
        ),
      );
    } else {
      _submitProfile(_existingImageUrl);
    }
  }

  void _submitProfile(String? imageUrl) {
    final profile = ProfileEntity(
      userId: widget.userId,
      name: _nameController.text.trim(),
      organization: _organizationController.text.trim().isEmpty
          ? null
          : _organizationController.text.trim(),
      profilePicUrl: imageUrl,
      skills: _selectedSkills,
      portfolioLink: _portfolioController.text.trim().isEmpty
          ? null
          : _portfolioController.text.trim(),
      githubLink: _githubController.text.trim().isEmpty
          ? null
          : _githubController.text.trim(),
      otherLinks: _otherLinksControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      createdAt: widget.existingProfile?.createdAt,
    );

    context.read<ProfileBloc>().add(
      SaveProfile(profile: profile, isNew: _isNewProfile),
    );
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return true;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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
          _isNewProfile ? l10n.createProfile : l10n.editProfile,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          ProfileEditAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),

          ProfileEditFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          SafeArea(
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfilePictureUploaded) {
                  _submitProfile(state.imageUrl);
                } else if (state is ProfileSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.profileSaved),
                        ],
                      ),
                      backgroundColor: AppColors.successDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  final unverifiedSkills = _selectedSkills
                      .where((s) => s.isApproved && !s.isVerified)
                      .toList();

                  sl<AuthBloc>().add(const CheckAuthStatusRequested());

                  if (unverifiedSkills.isNotEmpty) {
                    _showVerifySkillsPrompt(unverifiedSkills);
                  } else {
                    context.go(AppRoutes.home);
                  }
                } else if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading =
                    state is ProfileSaving || state is ProfilePictureUploading;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileEditPictureSection(
                              selectedImageFile: _selectedImageFile,
                              existingImageUrl: _existingImageUrl,
                              isDark: isDark,
                              isLoading: isLoading,
                              changePhotoLabel: l10n.changePhoto,
                              onTap: _showImagePicker,
                            ),
                            const SizedBox(height: 32),

                            ProfileEditFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: l10n.name,
                              hint: l10n.nameHint,
                              icon: Icons.person_outline_rounded,
                              isDark: isDark,
                              enabled: !isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.nameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            ProfileEditFormField(
                              controller: _organizationController,
                              focusNode: _organizationFocusNode,
                              label: l10n.organization,
                              hint: l10n.organizationHint,
                              icon: Icons.business_outlined,
                              isDark: isDark,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 28),

                            ProfileEditSkillsSection(
                              skills: _selectedSkills,
                              sectionTitle: l10n.skills,
                              addButtonLabel: l10n.addSkill,
                              emptyMessage: l10n.noSkillsAdded,
                              isDark: isDark,
                              isLoading: isLoading,
                              onAddTap: _showSkillsDialog,
                              onRemoveSkill: (skill) {
                                setState(() {
                                  _selectedSkills.removeWhere(
                                    (s) => s.skillName == skill.skillName,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 28),

                            ProfileEditFormField(
                              controller: _portfolioController,
                              focusNode: _portfolioFocusNode,
                              label: l10n.portfolioLink,
                              hint: l10n.portfolioHint,
                              icon: Icons.web_rounded,
                              isDark: isDark,
                              enabled: !isLoading,
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    !_isValidUrl(value)) {
                                  return l10n.invalidUrl;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            ProfileEditFormField(
                              controller: _githubController,
                              focusNode: _githubFocusNode,
                              label: l10n.githubLink,
                              hint: l10n.githubHint,
                              icon: Icons.code_rounded,
                              isDark: isDark,
                              enabled: !isLoading,
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    !_isValidUrl(value)) {
                                  return l10n.invalidUrl;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            ProfileEditOtherLinksSection(
                              controllers: _otherLinksControllers,
                              sectionTitle: l10n.otherLinks,
                              addButtonLabel: l10n.addLink,
                              linkHint: l10n.linkHint,
                              invalidUrlMessage: l10n.invalidUrl,
                              isDark: isDark,
                              isLoading: isLoading,
                              urlValidator: _isValidUrl,
                              onAddLink: _addOtherLink,
                              onRemoveLink: _removeOtherLink,
                            ),
                            const SizedBox(height: 36),

                            ProfileEditSaveButton(
                              label: l10n.save,
                              isLoading: isLoading,
                              onTap: _saveProfile,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    if (isLoading)
                      ProfileEditLoadingOverlay(
                        isDark: isDark,
                        message: state is ProfilePictureUploading
                            ? l10n.uploadingImage
                            : l10n.savingProfile,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
