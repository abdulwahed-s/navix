import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Navix'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored'**
  String get connectionRestored;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @welcomeToNavix.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Navix'**
  String get welcomeToNavix;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get registerSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get registering;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get registerSuccess;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An authentication error occurred'**
  String get authErrorUnknown;

  /// No description provided for @authErrorNetworkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get authErrorNetworkRequestFailed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get profileTitle;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself to get started'**
  String get completeProfileSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @organizationHint.
  ///
  /// In en, this message translates to:
  /// **'Company, university, or team (optional)'**
  String get organizationHint;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your skills'**
  String get skillsHint;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @removeSkill.
  ///
  /// In en, this message translates to:
  /// **'Remove Skill'**
  String get removeSkill;

  /// No description provided for @noSkillsAdded.
  ///
  /// In en, this message translates to:
  /// **'No skills added yet'**
  String get noSkillsAdded;

  /// No description provided for @selectSkills.
  ///
  /// In en, this message translates to:
  /// **'Select Skills'**
  String get selectSkills;

  /// No description provided for @customSkill.
  ///
  /// In en, this message translates to:
  /// **'Custom Skill'**
  String get customSkill;

  /// No description provided for @addCustomSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Skill'**
  String get addCustomSkill;

  /// No description provided for @portfolioLink.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioLink;

  /// No description provided for @portfolioHint.
  ///
  /// In en, this message translates to:
  /// **'https://yourportfolio.com'**
  String get portfolioHint;

  /// No description provided for @githubLink.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get githubLink;

  /// No description provided for @githubHint.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/username'**
  String get githubHint;

  /// No description provided for @otherLinks.
  ///
  /// In en, this message translates to:
  /// **'Other Links'**
  String get otherLinks;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get addLink;

  /// No description provided for @removeLink.
  ///
  /// In en, this message translates to:
  /// **'Remove Link'**
  String get removeLink;

  /// No description provided for @linkHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get linkHint;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get invalidUrl;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @savingProfile.
  ///
  /// In en, this message translates to:
  /// **'Saving profile...'**
  String get savingProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get profileSaveError;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @imageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get imageUploadError;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @projectIdeas.
  ///
  /// In en, this message translates to:
  /// **'Project Ideas'**
  String get projectIdeas;

  /// No description provided for @generateIdeas.
  ///
  /// In en, this message translates to:
  /// **'Generate Ideas'**
  String get generateIdeas;

  /// No description provided for @generatingIdeas.
  ///
  /// In en, this message translates to:
  /// **'Generating project ideas...'**
  String get generatingIdeas;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @selectProjectType.
  ///
  /// In en, this message translates to:
  /// **'What type of project interests you?'**
  String get selectProjectType;

  /// No description provided for @selectTeamSize.
  ///
  /// In en, this message translates to:
  /// **'Solo or Team?'**
  String get selectTeamSize;

  /// No description provided for @solo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get solo;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @soloDescription.
  ///
  /// In en, this message translates to:
  /// **'Work independently at your own pace'**
  String get soloDescription;

  /// No description provided for @teamDescription.
  ///
  /// In en, this message translates to:
  /// **'Collaborate with others'**
  String get teamDescription;

  /// No description provided for @whatAreYourGoals.
  ///
  /// In en, this message translates to:
  /// **'What are your goals?'**
  String get whatAreYourGoals;

  /// No description provided for @goalsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to achieve'**
  String get goalsHint;

  /// No description provided for @anyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Any preferences?'**
  String get anyPreferences;

  /// No description provided for @preferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Technologies, domains, or constraints'**
  String get preferencesHint;

  /// No description provided for @generateProjectIdeas.
  ///
  /// In en, this message translates to:
  /// **'Generate Project Ideas'**
  String get generateProjectIdeas;

  /// No description provided for @projectIdeaTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Ideas for You'**
  String get projectIdeaTitle;

  /// No description provided for @noIdeasGenerated.
  ///
  /// In en, this message translates to:
  /// **'No ideas generated yet'**
  String get noIdeasGenerated;

  /// No description provided for @selectThisIdea.
  ///
  /// In en, this message translates to:
  /// **'Select This Idea'**
  String get selectThisIdea;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @requiredSkills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills'**
  String get requiredSkills;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration'**
  String get estimatedDuration;

  /// No description provided for @complexity.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get complexity;

  /// No description provided for @feasibility.
  ///
  /// In en, this message translates to:
  /// **'Feasibility'**
  String get feasibility;

  /// No description provided for @complexityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get complexityLow;

  /// No description provided for @complexityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get complexityMedium;

  /// No description provided for @complexityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get complexityHigh;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String durationDays(int count);

  /// No description provided for @durationWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String durationWeeks(int count);

  /// No description provided for @durationMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String durationMonths(int count);

  /// No description provided for @aiErrorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate ideas. Please try again.'**
  String get aiErrorGeneral;

  /// No description provided for @aiErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get aiErrorRateLimit;

  /// No description provided for @aiErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get aiErrorNetwork;

  /// No description provided for @ideaSelected.
  ///
  /// In en, this message translates to:
  /// **'Idea selected!'**
  String get ideaSelected;

  /// No description provided for @regenerateIdeas.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Ideas'**
  String get regenerateIdeas;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get projectNameHint;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @projectDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your project'**
  String get projectDescriptionHint;

  /// No description provided for @teamSize.
  ///
  /// In en, this message translates to:
  /// **'Team Size'**
  String get teamSize;

  /// No description provided for @teamSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Number of team members'**
  String get teamSizeHint;

  /// No description provided for @projectTimeline.
  ///
  /// In en, this message translates to:
  /// **'Project Timeline'**
  String get projectTimeline;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectDates.
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get selectDates;

  /// No description provided for @generateRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Generate Roadmap'**
  String get generateRoadmap;

  /// No description provided for @generatingRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Generating roadmap...'**
  String get generatingRoadmap;

  /// No description provided for @roadmapGenerated.
  ///
  /// In en, this message translates to:
  /// **'Roadmap Generated'**
  String get roadmapGenerated;

  /// No description provided for @reviewRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Review your project roadmap'**
  String get reviewRoadmap;

  /// No description provided for @confirmAndCreate.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Create Project'**
  String get confirmAndCreate;

  /// No description provided for @creatingProject.
  ///
  /// In en, this message translates to:
  /// **'Creating project...'**
  String get creatingProject;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Project created successfully!'**
  String get projectCreated;

  /// No description provided for @projectCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project'**
  String get projectCreateError;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @milestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get milestone;

  /// No description provided for @milestoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Milestone Description'**
  String get milestoneDescription;

  /// No description provided for @milestoneName.
  ///
  /// In en, this message translates to:
  /// **'Milestone Name'**
  String get milestoneName;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editMilestone;

  /// No description provided for @deleteMilestone.
  ///
  /// In en, this message translates to:
  /// **'Delete Milestone'**
  String get deleteMilestone;

  /// No description provided for @milestoneDeadline.
  ///
  /// In en, this message translates to:
  /// **'Milestone Deadline'**
  String get milestoneDeadline;

  /// No description provided for @noMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet'**
  String get noMilestones;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskName;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign To'**
  String get assignTo;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @estimatedHours.
  ///
  /// In en, this message translates to:
  /// **'Estimated Hours'**
  String get estimatedHours;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get statusNotStarted;

  /// No description provided for @statusStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get statusStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusFixing.
  ///
  /// In en, this message translates to:
  /// **'Fixing'**
  String get statusFixing;

  /// No description provided for @statusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get statusBlocked;

  /// No description provided for @statusInReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get statusInReview;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @projectPhase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get projectPhase;

  /// No description provided for @phaseActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get phaseActive;

  /// No description provided for @phaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get phaseCompleted;

  /// No description provided for @phasePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get phasePaused;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @myProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myProjects;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjects;

  /// No description provided for @noProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first project to get started!'**
  String get noProjectsMessage;

  /// No description provided for @refreshProjects.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get refreshProjects;

  /// No description provided for @loadingProjects.
  ///
  /// In en, this message translates to:
  /// **'Loading projects...'**
  String get loadingProjects;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Complete'**
  String progressPercent(int percent);

  /// No description provided for @nextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next Milestone'**
  String get nextMilestone;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @completionStatus.
  ///
  /// In en, this message translates to:
  /// **'Completion Status'**
  String get completionStatus;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @roleLeader.
  ///
  /// In en, this message translates to:
  /// **'Project Leader'**
  String get roleLeader;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Team Member'**
  String get roleMember;

  /// No description provided for @workload.
  ///
  /// In en, this message translates to:
  /// **'Workload'**
  String get workload;

  /// No description provided for @tasksAssigned.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks assigned'**
  String tasksAssigned(int count);

  /// No description provided for @taskDistribution.
  ///
  /// In en, this message translates to:
  /// **'Task Distribution'**
  String get taskDistribution;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @yourTasks.
  ///
  /// In en, this message translates to:
  /// **'Your Tasks'**
  String get yourTasks;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get allTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// No description provided for @pendingTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pendingTasks;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @projectChat.
  ///
  /// In en, this message translates to:
  /// **'Project Chat'**
  String get projectChat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @updatePhase.
  ///
  /// In en, this message translates to:
  /// **'Update Phase'**
  String get updatePhase;

  /// No description provided for @reassignTask.
  ///
  /// In en, this message translates to:
  /// **'Reassign Task'**
  String get reassignTask;

  /// No description provided for @selectMember.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get selectMember;

  /// No description provided for @riskPrediction.
  ///
  /// In en, this message translates to:
  /// **'Risk Prediction'**
  String get riskPrediction;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @riskAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Risk Analysis'**
  String get riskAnalysis;

  /// No description provided for @projectHealth.
  ///
  /// In en, this message translates to:
  /// **'Project Health'**
  String get projectHealth;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @riskLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get riskLevelLow;

  /// No description provided for @riskLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get riskLevelMedium;

  /// No description provided for @riskLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskLevelHigh;

  /// No description provided for @delayProbability.
  ///
  /// In en, this message translates to:
  /// **'Delay Probability'**
  String get delayProbability;

  /// No description provided for @delayProbabilityPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% chance of delay'**
  String delayProbabilityPercent(int percent);

  /// No description provided for @atRiskTasks.
  ///
  /// In en, this message translates to:
  /// **'At-Risk Tasks'**
  String get atRiskTasks;

  /// No description provided for @blockedTasks.
  ///
  /// In en, this message translates to:
  /// **'Blocked Tasks'**
  String get blockedTasks;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @lastAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Last analyzed'**
  String get lastAnalyzed;

  /// No description provided for @analyzingProject.
  ///
  /// In en, this message translates to:
  /// **'Analyzing project...'**
  String get analyzingProject;

  /// No description provided for @noRisks.
  ///
  /// In en, this message translates to:
  /// **'No risks detected'**
  String get noRisks;

  /// No description provided for @noRisksMessage.
  ///
  /// In en, this message translates to:
  /// **'Your project is on track!'**
  String get noRisksMessage;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get actionRequired;

  /// No description provided for @refreshAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analysis'**
  String get refreshAnalysis;

  /// No description provided for @historicalPredictions.
  ///
  /// In en, this message translates to:
  /// **'Historical Predictions'**
  String get historicalPredictions;

  /// No description provided for @predictionHistory.
  ///
  /// In en, this message translates to:
  /// **'Prediction History'**
  String get predictionHistory;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// No description provided for @assignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// No description provided for @overdueTask.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTask;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String dueIn(int days);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @postComment.
  ///
  /// In en, this message translates to:
  /// **'Post Comment'**
  String get postComment;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdated;

  /// No description provided for @taskReassigned.
  ///
  /// In en, this message translates to:
  /// **'Task reassigned successfully'**
  String get taskReassigned;

  /// No description provided for @confirmReassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign Task'**
  String get confirmReassign;

  /// No description provided for @reassignMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a team member to assign this task to'**
  String get reassignMessage;

  /// No description provided for @taskHistory.
  ///
  /// In en, this message translates to:
  /// **'Task History'**
  String get taskHistory;

  /// No description provided for @statusChanged.
  ///
  /// In en, this message translates to:
  /// **'Status changed to {status}'**
  String statusChanged(String status);

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added'**
  String get commentAdded;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get confirmDelete;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @noEventsMessage.
  ///
  /// In en, this message translates to:
  /// **'No events on this day'**
  String get noEventsMessage;

  /// No description provided for @allProjects.
  ///
  /// In en, this message translates to:
  /// **'All Projects'**
  String get allProjects;

  /// No description provided for @filterByProject.
  ///
  /// In en, this message translates to:
  /// **'Filter by Project'**
  String get filterByProject;

  /// No description provided for @taskDeadline.
  ///
  /// In en, this message translates to:
  /// **'Task Deadline'**
  String get taskDeadline;

  /// No description provided for @meeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meeting;

  /// No description provided for @viewEvent.
  ///
  /// In en, this message translates to:
  /// **'View Event'**
  String get viewEvent;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @eventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String eventsCount(int count);

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @pastEvents.
  ///
  /// In en, this message translates to:
  /// **'Past Events'**
  String get pastEvents;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @findPeople.
  ///
  /// In en, this message translates to:
  /// **'Find People'**
  String get findPeople;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @filterBySkills.
  ///
  /// In en, this message translates to:
  /// **'Filter by Skills'**
  String get filterBySkills;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noUsersFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get noUsersFoundMessage;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @inviteToProject.
  ///
  /// In en, this message translates to:
  /// **'Invite to Project'**
  String get inviteToProject;

  /// No description provided for @connectionSent.
  ///
  /// In en, this message translates to:
  /// **'Connection request sent'**
  String get connectionSent;

  /// No description provided for @alreadySent.
  ///
  /// In en, this message translates to:
  /// **'Already Sent'**
  String get alreadySent;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @expertiseLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Expertise Level'**
  String get expertiseLevelLabel;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// No description provided for @activeProjectsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active projects'**
  String activeProjectsCount(int count);

  /// No description provided for @usersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} users found'**
  String usersFound(int count);

  /// No description provided for @connectionRequest.
  ///
  /// In en, this message translates to:
  /// **'Connection Request'**
  String get connectionRequest;

  /// No description provided for @connectionRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to connect'**
  String connectionRequestFrom(String name);

  /// No description provided for @acceptConnection.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptConnection;

  /// No description provided for @rejectConnection.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectConnection;

  /// No description provided for @connectionAccepted.
  ///
  /// In en, this message translates to:
  /// **'Connection accepted'**
  String get connectionAccepted;

  /// No description provided for @connectionRejected.
  ///
  /// In en, this message translates to:
  /// **'Connection rejected'**
  String get connectionRejected;

  /// No description provided for @alreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get alreadyConnected;

  /// No description provided for @cancelConnection.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelConnection;

  /// No description provided for @confirmCancelConnection.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this connection request?'**
  String get confirmCancelConnection;

  /// No description provided for @connectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Connection request cancelled'**
  String get connectionCancelled;

  /// No description provided for @removeConnection.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeConnection;

  /// No description provided for @confirmRemoveConnection.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this connection?'**
  String get confirmRemoveConnection;

  /// No description provided for @connectionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Connection removed'**
  String get connectionRemoved;

  /// No description provided for @respond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get respond;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @lastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get lastMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// No description provided for @confirmDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation?'**
  String get confirmDeleteConversation;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadMessages(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// No description provided for @connectedPeople.
  ///
  /// In en, this message translates to:
  /// **'Connected People'**
  String get connectedPeople;

  /// No description provided for @noConnectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No connections yet'**
  String get noConnectionsYet;

  /// No description provided for @noConnectionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect with people from Find People tab'**
  String get noConnectionsMessage;

  /// No description provided for @selectPersonToChat.
  ///
  /// In en, this message translates to:
  /// **'Select a person to start chatting'**
  String get selectPersonToChat;

  /// No description provided for @loadingConnections.
  ///
  /// In en, this message translates to:
  /// **'Loading connections...'**
  String get loadingConnections;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettings;

  /// No description provided for @taskAssignments.
  ///
  /// In en, this message translates to:
  /// **'Task Assignments'**
  String get taskAssignments;

  /// No description provided for @taskAssignmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when assigned to new tasks'**
  String get taskAssignmentsDesc;

  /// No description provided for @projectUpdates.
  ///
  /// In en, this message translates to:
  /// **'Project Updates'**
  String get projectUpdates;

  /// No description provided for @projectUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about project changes'**
  String get projectUpdatesDesc;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messageNotifications;

  /// No description provided for @messageNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new messages'**
  String get messageNotificationsDesc;

  /// No description provided for @riskAlerts.
  ///
  /// In en, this message translates to:
  /// **'Risk Alerts'**
  String get riskAlerts;

  /// No description provided for @riskAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about project risks'**
  String get riskAlertsDesc;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettings;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @publicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicProfile;

  /// No description provided for @privateProfile.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateProfile;

  /// No description provided for @whoCanFindYou.
  ///
  /// In en, this message translates to:
  /// **'Who Can Find You'**
  String get whoCanFindYou;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @connectionsOnly.
  ///
  /// In en, this message translates to:
  /// **'Connections Only'**
  String get connectionsOnly;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @notificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationCenter;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @confirmClearNotifications.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications?'**
  String get confirmClearNotifications;

  /// No description provided for @notificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'Notifications cleared'**
  String get notificationsCleared;

  /// No description provided for @taskAssignedNotification.
  ///
  /// In en, this message translates to:
  /// **'You have been assigned to a task'**
  String get taskAssignedNotification;

  /// No description provided for @taskDueSoonNotification.
  ///
  /// In en, this message translates to:
  /// **'Task due in {hours} hours'**
  String taskDueSoonNotification(int hours);

  /// No description provided for @taskOverdueNotification.
  ///
  /// In en, this message translates to:
  /// **'Task is overdue'**
  String get taskOverdueNotification;

  /// No description provided for @milestoneReachedNotification.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached'**
  String get milestoneReachedNotification;

  /// No description provided for @highRiskDetectedNotification.
  ///
  /// In en, this message translates to:
  /// **'High risk detected in project'**
  String get highRiskDetectedNotification;

  /// No description provided for @newMessageNotification.
  ///
  /// In en, this message translates to:
  /// **'New message from {sender}'**
  String newMessageNotification(String sender);

  /// No description provided for @projectInvitationNotification.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join {project}'**
  String projectInvitationNotification(String project);

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// No description provided for @enableInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable in Settings'**
  String get enableInSettings;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied'**
  String get notificationPermissionDenied;

  /// No description provided for @haveAnIdea.
  ///
  /// In en, this message translates to:
  /// **'I have an idea'**
  String get haveAnIdea;

  /// No description provided for @submitIdea.
  ///
  /// In en, this message translates to:
  /// **'Submit Idea'**
  String get submitIdea;

  /// No description provided for @describeYourIdea.
  ///
  /// In en, this message translates to:
  /// **'Describe your project idea in detail...'**
  String get describeYourIdea;

  /// No description provided for @refineIdea.
  ///
  /// In en, this message translates to:
  /// **'Refine with AI'**
  String get refineIdea;

  /// No description provided for @refiningIdea.
  ///
  /// In en, this message translates to:
  /// **'Refining your idea...'**
  String get refiningIdea;

  /// No description provided for @refinedIdea.
  ///
  /// In en, this message translates to:
  /// **'Refined Idea'**
  String get refinedIdea;

  /// No description provided for @improvedDescription.
  ///
  /// In en, this message translates to:
  /// **'Improved Description'**
  String get improvedDescription;

  /// No description provided for @scopeClarification.
  ///
  /// In en, this message translates to:
  /// **'Scope Clarification'**
  String get scopeClarification;

  /// No description provided for @suggestedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Suggested Features'**
  String get suggestedFeatures;

  /// No description provided for @feasibilityAssessment.
  ///
  /// In en, this message translates to:
  /// **'Feasibility Assessment'**
  String get feasibilityAssessment;

  /// No description provided for @yourSkills.
  ///
  /// In en, this message translates to:
  /// **'Your Skills'**
  String get yourSkills;

  /// No description provided for @missingSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills to Learn'**
  String get missingSkills;

  /// No description provided for @acceptRefinement.
  ///
  /// In en, this message translates to:
  /// **'Accept & Create Project'**
  String get acceptRefinement;

  /// No description provided for @refineAgain.
  ///
  /// In en, this message translates to:
  /// **'Refine Again'**
  String get refineAgain;

  /// No description provided for @ideaRefinementSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your idea has been refined successfully'**
  String get ideaRefinementSuccess;

  /// No description provided for @ideaRefinementError.
  ///
  /// In en, this message translates to:
  /// **'Failed to refine your idea. Please try again.'**
  String get ideaRefinementError;

  /// No description provided for @provideMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Add more details to refine further...'**
  String get provideMoreDetails;

  /// No description provided for @feasibilityScore.
  ///
  /// In en, this message translates to:
  /// **'Feasibility: {score}/10'**
  String feasibilityScore(int score);

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String characterCount(int count);

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 50 characters required'**
  String get minCharacters;

  /// No description provided for @teamManagement.
  ///
  /// In en, this message translates to:
  /// **'Team Management'**
  String get teamManagement;

  /// No description provided for @manageTeam.
  ///
  /// In en, this message translates to:
  /// **'Manage Team'**
  String get manageTeam;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @selectMembers.
  ///
  /// In en, this message translates to:
  /// **'Select Members'**
  String get selectMembers;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search for members...'**
  String get searchMembers;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @confirmRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the project?'**
  String confirmRemoveMember(String name);

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get memberRemoved;

  /// No description provided for @inviteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a message'**
  String get inviteMessageTitle;

  /// No description provided for @inviteMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you inviting them? (optional)'**
  String get inviteMessageHint;

  /// No description provided for @skipMessage.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipMessage;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInvite;

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted'**
  String get invitationAccepted;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @invitationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled'**
  String get invitationCancelled;

  /// No description provided for @cancelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelInvitation;

  /// No description provided for @cancelInvitationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation to {name}?'**
  String cancelInvitationConfirm(String name);

  /// No description provided for @pendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @acceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptInvitation;

  /// No description provided for @declineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineInvitation;

  /// No description provided for @invitedBy.
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String invitedBy(String name);

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @makeLeader.
  ///
  /// In en, this message translates to:
  /// **'Make Leader'**
  String get makeLeader;

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make Member'**
  String get makeMember;

  /// No description provided for @roleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed successfully'**
  String get roleChanged;

  /// No description provided for @projectLeader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get projectLeader;

  /// No description provided for @projectMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get projectMember;

  /// No description provided for @assignedTasks.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks assigned'**
  String assignedTasks(int count);

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}% complete'**
  String completionRate(int rate);

  /// No description provided for @taskReassignmentWarning.
  ///
  /// In en, this message translates to:
  /// **'This member\'s tasks will need to be reassigned.'**
  String get taskReassignmentWarning;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @createFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Create your first project'**
  String get createFirstProject;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'No team members'**
  String get noTeamMembers;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone to your project'**
  String get inviteSomeone;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get retryConnection;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @completeProfileToContinue.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue'**
  String get completeProfileToContinue;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @profileRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile information is required to use the app'**
  String get profileRequired;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @chooseProjectPath.
  ///
  /// In en, this message translates to:
  /// **'How would you like to start?'**
  String get chooseProjectPath;

  /// No description provided for @choosePathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an option to begin your project journey'**
  String get choosePathSubtitle;

  /// No description provided for @iHaveAnIdea.
  ///
  /// In en, this message translates to:
  /// **'I have an idea'**
  String get iHaveAnIdea;

  /// No description provided for @iHaveAnIdeaDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit your idea and let AI help refine it'**
  String get iHaveAnIdeaDesc;

  /// No description provided for @iDontHaveIdea.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an idea'**
  String get iDontHaveIdea;

  /// No description provided for @iDontHaveIdeaDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer questions and let AI generate ideas for you'**
  String get iDontHaveIdeaDesc;

  /// No description provided for @teamSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Team Size'**
  String get teamSizeLabel;

  /// No description provided for @teamSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'How many members will work on this project?'**
  String get teamSizeDesc;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String members(int count);

  /// No description provided for @brainstormingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Let\'s brainstorm your project'**
  String get brainstormingQuestions;

  /// No description provided for @tellUsAboutYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your team'**
  String get tellUsAboutYourTeam;

  /// No description provided for @teamMemberSkills.
  ///
  /// In en, this message translates to:
  /// **'Team Member {number} Skills'**
  String teamMemberSkills(int number);

  /// No description provided for @addSkillsForMember.
  ///
  /// In en, this message translates to:
  /// **'Add skills for this team member'**
  String get addSkillsForMember;

  /// No description provided for @yourInterests.
  ///
  /// In en, this message translates to:
  /// **'What are your interests?'**
  String get yourInterests;

  /// No description provided for @interestsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., AI, web development, mobile apps, data science'**
  String get interestsHint;

  /// No description provided for @preferredTechnologies.
  ///
  /// In en, this message translates to:
  /// **'Preferred Technologies'**
  String get preferredTechnologies;

  /// No description provided for @technologiesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Flutter, React, Python, TensorFlow'**
  String get technologiesHint;

  /// No description provided for @projectDomain.
  ///
  /// In en, this message translates to:
  /// **'Project Domain'**
  String get projectDomain;

  /// No description provided for @selectDomains.
  ///
  /// In en, this message translates to:
  /// **'Select domains that interest you'**
  String get selectDomains;

  /// No description provided for @webDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Web Development'**
  String get webDevelopment;

  /// No description provided for @mobileDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Mobile Development'**
  String get mobileDevelopment;

  /// No description provided for @artificialIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence'**
  String get artificialIntelligence;

  /// No description provided for @dataScience.
  ///
  /// In en, this message translates to:
  /// **'Data Science'**
  String get dataScience;

  /// No description provided for @gamesDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Games Development'**
  String get gamesDevelopment;

  /// No description provided for @iotEmbedded.
  ///
  /// In en, this message translates to:
  /// **'IoT & Embedded Systems'**
  String get iotEmbedded;

  /// No description provided for @blockchain.
  ///
  /// In en, this message translates to:
  /// **'Blockchain'**
  String get blockchain;

  /// No description provided for @cybersecurity.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity'**
  String get cybersecurity;

  /// No description provided for @timeCommitment.
  ///
  /// In en, this message translates to:
  /// **'Time Commitment'**
  String get timeCommitment;

  /// No description provided for @hoursPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Hours per week'**
  String get hoursPerWeek;

  /// No description provided for @hoursPerWeekHint.
  ///
  /// In en, this message translates to:
  /// **'How many hours can you dedicate weekly?'**
  String get hoursPerWeekHint;

  /// No description provided for @learningGoals.
  ///
  /// In en, this message translates to:
  /// **'Learning Goals'**
  String get learningGoals;

  /// No description provided for @learningGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Learn machine learning, improve backend skills'**
  String get learningGoalsHint;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInfo;

  /// No description provided for @additionalInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Any other information that might help generate better ideas'**
  String get additionalInfoHint;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @skipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipStep;

  /// No description provided for @continueToNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToNext;

  /// No description provided for @teamMemberSkillsDesc.
  ///
  /// In en, this message translates to:
  /// **'List the skills of each team member'**
  String get teamMemberSkillsDesc;

  /// No description provided for @teamMemberSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., John: Flutter, Dart; Sarah: Python, ML'**
  String get teamMemberSkillsHint;

  /// No description provided for @yourInterestsDesc.
  ///
  /// In en, this message translates to:
  /// **'What topics or areas are you passionate about?'**
  String get yourInterestsDesc;

  /// No description provided for @yourInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Healthcare, Education, Gaming, Social Impact'**
  String get yourInterestsHint;

  /// No description provided for @preferredTechnologiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Which technologies would you like to use or learn?'**
  String get preferredTechnologiesDesc;

  /// No description provided for @preferredTechnologiesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Flutter, React, Python, TensorFlow, Firebase'**
  String get preferredTechnologiesHint;

  /// No description provided for @projectDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'Select one or more domains for your project'**
  String get projectDomainDesc;

  /// No description provided for @timeCommitmentDesc.
  ///
  /// In en, this message translates to:
  /// **'How much time can you dedicate to this project?'**
  String get timeCommitmentDesc;

  /// No description provided for @timeCommitmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 3 months, 10 hours per week'**
  String get timeCommitmentHint;

  /// No description provided for @learningGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'What do you want to learn from this project?'**
  String get learningGoalsDesc;

  /// No description provided for @generatedIdeas.
  ///
  /// In en, this message translates to:
  /// **'Generated Project Ideas'**
  String get generatedIdeas;

  /// No description provided for @selectIdeaToStart.
  ///
  /// In en, this message translates to:
  /// **'Select an idea to start your project'**
  String get selectIdeaToStart;

  /// No description provided for @weeksEstimate.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String weeksEstimate(int weeks);

  /// No description provided for @projectSettings.
  ///
  /// In en, this message translates to:
  /// **'Project Settings'**
  String get projectSettings;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @roleAssignments.
  ///
  /// In en, this message translates to:
  /// **'Role Assignments'**
  String get roleAssignments;

  /// No description provided for @assignRole.
  ///
  /// In en, this message translates to:
  /// **'Assign Role'**
  String get assignRole;

  /// No description provided for @assignMember.
  ///
  /// In en, this message translates to:
  /// **'Assign Member'**
  String get assignMember;

  /// No description provided for @roleAssignedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Role assigned successfully'**
  String get roleAssignedSuccess;

  /// No description provided for @noRoles.
  ///
  /// In en, this message translates to:
  /// **'No roles defined for this project'**
  String get noRoles;

  /// No description provided for @tasksForRole.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String tasksForRole(int count);

  /// No description provided for @requiredRole.
  ///
  /// In en, this message translates to:
  /// **'Required Role'**
  String get requiredRole;

  /// No description provided for @roleDescription.
  ///
  /// In en, this message translates to:
  /// **'Role Description'**
  String get roleDescription;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group By'**
  String get groupBy;

  /// No description provided for @groupByNone.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get groupByNone;

  /// No description provided for @groupByRole.
  ///
  /// In en, this message translates to:
  /// **'Group by Role'**
  String get groupByRole;

  /// No description provided for @groupByTime.
  ///
  /// In en, this message translates to:
  /// **'Group by Time'**
  String get groupByTime;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @urgencyLow.
  ///
  /// In en, this message translates to:
  /// **'Low Urgency'**
  String get urgencyLow;

  /// No description provided for @urgencyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Urgency'**
  String get urgencyMedium;

  /// No description provided for @urgencyHigh.
  ///
  /// In en, this message translates to:
  /// **'High Urgency'**
  String get urgencyHigh;

  /// No description provided for @urgencyCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical Urgency'**
  String get urgencyCritical;

  /// No description provided for @overdueWarning.
  ///
  /// In en, this message translates to:
  /// **'Overdue!'**
  String get overdueWarning;

  /// No description provided for @tasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get tasksDueToday;

  /// No description provided for @tasksDueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get tasksDueThisWeek;

  /// No description provided for @tasksOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasksOverdue;

  /// No description provided for @tasksLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get tasksLater;

  /// No description provided for @noTasksInGroup.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this group'**
  String get noTasksInGroup;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get filterByRole;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @noRoleAssigned.
  ///
  /// In en, this message translates to:
  /// **'No Role Assigned'**
  String get noRoleAssigned;

  /// No description provided for @allPeriods.
  ///
  /// In en, this message translates to:
  /// **'All Periods'**
  String get allPeriods;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterBy;

  /// No description provided for @priorityHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Priority: High → Low'**
  String get priorityHighToLow;

  /// No description provided for @priorityLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Priority: Low → High'**
  String get priorityLowToHigh;

  /// No description provided for @deadlineAscending.
  ///
  /// In en, this message translates to:
  /// **'Deadline: Earliest First'**
  String get deadlineAscending;

  /// No description provided for @deadlineDescending.
  ///
  /// In en, this message translates to:
  /// **'Deadline: Latest First'**
  String get deadlineDescending;

  /// No description provided for @noSorting.
  ///
  /// In en, this message translates to:
  /// **'Default Order'**
  String get noSorting;

  /// No description provided for @tasksInGroup.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String tasksInGroup(int count);

  /// No description provided for @chatWithNavixAI.
  ///
  /// In en, this message translates to:
  /// **'Chat with Navix AI'**
  String get chatWithNavixAI;

  /// No description provided for @viewContext.
  ///
  /// In en, this message translates to:
  /// **'View Context'**
  String get viewContext;

  /// No description provided for @welcomeToNavixAI.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Navix AI'**
  String get welcomeToNavixAI;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your project or task'**
  String get askMeAnything;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @conversationContext.
  ///
  /// In en, this message translates to:
  /// **'Conversation Context'**
  String get conversationContext;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailedDescription;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @communityFeed.
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get communityFeed;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @postContent.
  ///
  /// In en, this message translates to:
  /// **'Post Content'**
  String get postContent;

  /// No description provided for @postTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s your post about?'**
  String get postTitleHint;

  /// No description provided for @postContentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, ideas, or questions...'**
  String get postContentHint;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @postImage.
  ///
  /// In en, this message translates to:
  /// **'Post Image'**
  String get postImage;

  /// No description provided for @textPost.
  ///
  /// In en, this message translates to:
  /// **'Text Post'**
  String get textPost;

  /// No description provided for @imagePost.
  ///
  /// In en, this message translates to:
  /// **'Image Post'**
  String get imagePost;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get sortHot;

  /// No description provided for @sortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get sortLatest;

  /// No description provided for @sortTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get sortTop;

  /// No description provided for @upvote.
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get upvote;

  /// No description provided for @downvote.
  ///
  /// In en, this message translates to:
  /// **'Downvote'**
  String get downvote;

  /// No description provided for @voteCount.
  ///
  /// In en, this message translates to:
  /// **'{count} votes'**
  String voteCount(int count);

  /// No description provided for @upvoted.
  ///
  /// In en, this message translates to:
  /// **'Upvoted'**
  String get upvoted;

  /// No description provided for @downvoted.
  ///
  /// In en, this message translates to:
  /// **'Downvoted'**
  String get downvoted;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String replyTo(String name);

  /// No description provided for @commentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No comments} =1{1 comment} other{{count} comments}}'**
  String commentCount(int count);

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @beTheFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment'**
  String get beTheFirst;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get writeComment;

  /// No description provided for @writeReply.
  ///
  /// In en, this message translates to:
  /// **'Write a reply'**
  String get writeReply;

  /// No description provided for @postReply.
  ///
  /// In en, this message translates to:
  /// **'Post Reply'**
  String get postReply;

  /// No description provided for @loadMoreReplies.
  ///
  /// In en, this message translates to:
  /// **'Load more replies'**
  String get loadMoreReplies;

  /// No description provided for @viewReplies.
  ///
  /// In en, this message translates to:
  /// **'View {count} replies'**
  String viewReplies(int count);

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hideReplies;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @confirmDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get confirmDeletePost;

  /// No description provided for @confirmDeleteComment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get confirmDeleteComment;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get postDeleted;

  /// No description provided for @commentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted'**
  String get commentDeleted;

  /// No description provided for @postUpdated.
  ///
  /// In en, this message translates to:
  /// **'Post updated'**
  String get postUpdated;

  /// No description provided for @commentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment updated'**
  String get commentUpdated;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @reportComment.
  ///
  /// In en, this message translates to:
  /// **'Report Comment'**
  String get reportComment;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Report Reason'**
  String get reportReason;

  /// No description provided for @spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @inappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get inappropriateContent;

  /// No description provided for @harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassment;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get reportReasonHint;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitted;

  /// No description provided for @thankYouForReport.
  ///
  /// In en, this message translates to:
  /// **'Thank you for helping keep our community safe'**
  String get thankYouForReport;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share Post'**
  String get sharePost;

  /// No description provided for @shareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get shareVia;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully'**
  String get postCreated;

  /// No description provided for @postCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create post'**
  String get postCreateError;

  /// No description provided for @creatingPost.
  ///
  /// In en, this message translates to:
  /// **'Creating post...'**
  String get creatingPost;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @titleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 10 characters'**
  String get titleTooShort;

  /// No description provided for @titleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title must be less than 300 characters'**
  String get titleTooLong;

  /// No description provided for @contentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get contentRequired;

  /// No description provided for @contentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Content must be less than 10,000 characters'**
  String get contentTooLong;

  /// No description provided for @commentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Comment must be less than 2,000 characters'**
  String get commentTooLong;

  /// No description provided for @loadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Loading posts...'**
  String get loadingPosts;

  /// No description provided for @loadingComments.
  ///
  /// In en, this message translates to:
  /// **'Loading comments...'**
  String get loadingComments;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @beTheFirstToPost.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share something!'**
  String get beTheFirstToPost;

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by {username}'**
  String postedBy(String username);

  /// No description provided for @postedTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String postedTimeAgo(String time);

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @editedLabel.
  ///
  /// In en, this message translates to:
  /// **'(edited)'**
  String get editedLabel;

  /// No description provided for @characterCounter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max}'**
  String characterCounter(int current, int max);

  /// No description provided for @discardPost.
  ///
  /// In en, this message translates to:
  /// **'Discard Post'**
  String get discardPost;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// No description provided for @confirmDiscardPost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this post?'**
  String get confirmDiscardPost;

  /// No description provided for @confirmDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them?'**
  String get confirmDiscardChanges;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @userPosts.
  ///
  /// In en, this message translates to:
  /// **'{username}\'s Posts'**
  String userPosts(String username);

  /// No description provided for @postCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No posts} =1{1 post} other{{count} posts}}'**
  String postCount(int count);

  /// No description provided for @viewFullImage.
  ///
  /// In en, this message translates to:
  /// **'View Full Image'**
  String get viewFullImage;

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// No description provided for @retryImageLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryImageLoad;

  /// No description provided for @commentNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'New comment on your post'**
  String get commentNotificationTitle;

  /// No description provided for @commentNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{username} commented on your post'**
  String commentNotificationBody(String username);

  /// No description provided for @replyNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'New reply to your comment'**
  String get replyNotificationTitle;

  /// No description provided for @replyNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{username} replied to your comment'**
  String replyNotificationBody(String username);

  /// No description provided for @upvoteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your post is popular!'**
  String get upvoteNotificationTitle;

  /// No description provided for @upvoteNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your post has reached {count} upvotes'**
  String upvoteNotificationBody(int count);

  /// No description provided for @shareToChat.
  ///
  /// In en, this message translates to:
  /// **'Share to Chat'**
  String get shareToChat;

  /// No description provided for @shareToApp.
  ///
  /// In en, this message translates to:
  /// **'Share to App'**
  String get shareToApp;

  /// No description provided for @selectContact.
  ///
  /// In en, this message translates to:
  /// **'Select a connection'**
  String get selectContact;

  /// No description provided for @noConnections.
  ///
  /// In en, this message translates to:
  /// **'No connections yet'**
  String get noConnections;

  /// No description provided for @postShared.
  ///
  /// In en, this message translates to:
  /// **'Post shared successfully'**
  String get postShared;

  /// No description provided for @sharingPost.
  ///
  /// In en, this message translates to:
  /// **'Sharing post...'**
  String get sharingPost;

  /// No description provided for @editPostInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit your post title and content. Images cannot be changed.'**
  String get editPostInfo;

  /// No description provided for @imageCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Images cannot be changed after posting.'**
  String get imageCannotBeChanged;

  /// No description provided for @editWithAI.
  ///
  /// In en, this message translates to:
  /// **'Edit with AI'**
  String get editWithAI;

  /// No description provided for @aiProjectSupervisor.
  ///
  /// In en, this message translates to:
  /// **'AI Project Supervisor'**
  String get aiProjectSupervisor;

  /// No description provided for @aiSupervisorDescription.
  ///
  /// In en, this message translates to:
  /// **'Discuss project changes, deadlines, and features with Navix AI'**
  String get aiSupervisorDescription;

  /// No description provided for @askAboutProject.
  ///
  /// In en, this message translates to:
  /// **'Ask about your project...'**
  String get askAboutProject;

  /// No description provided for @suggestedActions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Actions'**
  String get suggestedActions;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Keep as is'**
  String get rejectAction;

  /// No description provided for @actionExecuted.
  ///
  /// In en, this message translates to:
  /// **'Action completed'**
  String get actionExecuted;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to execute action'**
  String get actionFailed;

  /// No description provided for @deadlineChanged.
  ///
  /// In en, this message translates to:
  /// **'Deadline changed successfully'**
  String get deadlineChanged;

  /// No description provided for @tasksAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task added} other{{count} tasks added}}'**
  String tasksAdded(int count);

  /// No description provided for @milestoneAdded.
  ///
  /// In en, this message translates to:
  /// **'Milestone added successfully'**
  String get milestoneAdded;

  /// No description provided for @examplePrompts.
  ///
  /// In en, this message translates to:
  /// **'Try asking...'**
  String get examplePrompts;

  /// No description provided for @exampleDeadlineChange.
  ///
  /// In en, this message translates to:
  /// **'The deadline has changed to January 30th'**
  String get exampleDeadlineChange;

  /// No description provided for @exampleAddFeature.
  ///
  /// In en, this message translates to:
  /// **'I want to add a user authentication feature'**
  String get exampleAddFeature;

  /// No description provided for @exampleProjectHealth.
  ///
  /// In en, this message translates to:
  /// **'Is the project on track to finish on time?'**
  String get exampleProjectHealth;

  /// No description provided for @exampleTeamIssue.
  ///
  /// In en, this message translates to:
  /// **'One team member can\'t work for 3 weeks'**
  String get exampleTeamIssue;

  /// No description provided for @aiThinkingAboutProject.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your project...'**
  String get aiThinkingAboutProject;

  /// No description provided for @noChangesNeeded.
  ///
  /// In en, this message translates to:
  /// **'No changes needed'**
  String get noChangesNeeded;

  /// No description provided for @projectAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Project Analysis'**
  String get projectAnalysis;

  /// No description provided for @recommendedChanges.
  ///
  /// In en, this message translates to:
  /// **'Recommended Changes'**
  String get recommendedChanges;

  /// No description provided for @skillVerification.
  ///
  /// In en, this message translates to:
  /// **'Skill Verification'**
  String get skillVerification;

  /// No description provided for @generatingTest.
  ///
  /// In en, this message translates to:
  /// **'Generating your test...'**
  String get generatingTest;

  /// No description provided for @evaluatingAnswers.
  ///
  /// In en, this message translates to:
  /// **'Evaluating your answers...'**
  String get evaluatingAnswers;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @submitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get submitTest;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @skipQuestion.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get skipQuestion;

  /// No description provided for @exitTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Test?'**
  String get exitTestTitle;

  /// No description provided for @exitTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost if you exit now.'**
  String get exitTestMessage;

  /// No description provided for @continueTest.
  ///
  /// In en, this message translates to:
  /// **'Continue Test'**
  String get continueTest;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @testComplete.
  ///
  /// In en, this message translates to:
  /// **'Test Complete!'**
  String get testComplete;

  /// No description provided for @verifyYourSkills.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Skills'**
  String get verifyYourSkills;

  /// No description provided for @verifySkillsPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have added skills that need verification. Take a quick test to verify your proficiency.'**
  String get verifySkillsPrompt;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @skillsVerifiedAndSaved.
  ///
  /// In en, this message translates to:
  /// **'Skills verified and saved!'**
  String get skillsVerifiedAndSaved;

  /// No description provided for @skillsVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Skills verified successfully!'**
  String get skillsVerifiedSuccess;

  /// No description provided for @skillAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Skill already added'**
  String get skillAlreadyAdded;

  /// No description provided for @invalidSkillRejected.
  ///
  /// In en, this message translates to:
  /// **'Invalid skill: \"{skill}\" is not recognized as a valid skill'**
  String invalidSkillRejected(String skill);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @verifySkills.
  ///
  /// In en, this message translates to:
  /// **'Verify Skills'**
  String get verifySkills;

  /// No description provided for @skillNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Skill name is too short (minimum 2 characters)'**
  String get skillNameTooShort;

  /// No description provided for @skillNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Skill name is too long (maximum 50 characters)'**
  String get skillNameTooLong;

  /// No description provided for @skillNameTooManyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Skill name contains too many numbers'**
  String get skillNameTooManyNumbers;

  /// No description provided for @skillNameTooManySpecial.
  ///
  /// In en, this message translates to:
  /// **'Skill name contains too many special characters'**
  String get skillNameTooManySpecial;

  /// No description provided for @skillNameRandomChars.
  ///
  /// In en, this message translates to:
  /// **'Skill name appears to be random characters'**
  String get skillNameRandomChars;

  /// No description provided for @enterYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer...'**
  String get enterYourAnswer;

  /// No description provided for @provideDetailedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Provide a detailed explanation...'**
  String get provideDetailedExplanation;

  /// No description provided for @surveys.
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get surveys;

  /// No description provided for @survey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get survey;

  /// No description provided for @createSurvey.
  ///
  /// In en, this message translates to:
  /// **'Create Survey'**
  String get createSurvey;

  /// No description provided for @noSurveys.
  ///
  /// In en, this message translates to:
  /// **'No surveys yet'**
  String get noSurveys;

  /// No description provided for @createFirstSurvey.
  ///
  /// In en, this message translates to:
  /// **'Create your first survey to gather feedback'**
  String get createFirstSurvey;

  /// No description provided for @surveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe your survey'**
  String get surveyDescription;

  /// No description provided for @surveyDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what kind of survey you want to create...'**
  String get surveyDescriptionHint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @fypSurvey.
  ///
  /// In en, this message translates to:
  /// **'FYP Survey'**
  String get fypSurvey;

  /// No description provided for @fypSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Problem validation & user feedback'**
  String get fypSurveyDescription;

  /// No description provided for @featureSurvey.
  ///
  /// In en, this message translates to:
  /// **'Feature Feedback'**
  String get featureSurvey;

  /// No description provided for @featureSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Feature usage & improvements'**
  String get featureSurveyDescription;

  /// No description provided for @userTestingSurvey.
  ///
  /// In en, this message translates to:
  /// **'User Testing'**
  String get userTestingSurvey;

  /// No description provided for @userTestingSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Usability & satisfaction'**
  String get userTestingSurveyDescription;

  /// No description provided for @customSurvey.
  ///
  /// In en, this message translates to:
  /// **'Custom Survey'**
  String get customSurvey;

  /// No description provided for @customSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your own survey'**
  String get customSurveyDescription;

  /// No description provided for @generateSurvey.
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get generateSurvey;

  /// No description provided for @generatingSurvey.
  ///
  /// In en, this message translates to:
  /// **'Generating survey...'**
  String get generatingSurvey;

  /// No description provided for @surveyGenerated.
  ///
  /// In en, this message translates to:
  /// **'Survey generated successfully'**
  String get surveyGenerated;

  /// No description provided for @surveyCreated.
  ///
  /// In en, this message translates to:
  /// **'Survey created successfully'**
  String get surveyCreated;

  /// No description provided for @deleteSurvey.
  ///
  /// In en, this message translates to:
  /// **'Delete Survey'**
  String get deleteSurvey;

  /// No description provided for @confirmDeleteSurvey.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this survey? All responses will be lost.'**
  String get confirmDeleteSurvey;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @responses.
  ///
  /// In en, this message translates to:
  /// **'responses'**
  String get responses;

  /// No description provided for @responseVisualization.
  ///
  /// In en, this message translates to:
  /// **'Response Visualization'**
  String get responseVisualization;

  /// No description provided for @noResponsesYet.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get noResponsesYet;

  /// No description provided for @takeSurvey.
  ///
  /// In en, this message translates to:
  /// **'Take Survey'**
  String get takeSurvey;

  /// No description provided for @submitResponse.
  ///
  /// In en, this message translates to:
  /// **'Submit Response'**
  String get submitResponse;

  /// No description provided for @responseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Response submitted successfully'**
  String get responseSubmitted;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description or select a template'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Please answer all required questions'**
  String get pleaseAnswerRequired;

  /// No description provided for @typeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get typeYourAnswer;

  /// No description provided for @shareSurvey.
  ///
  /// In en, this message translates to:
  /// **'Share Survey'**
  String get shareSurvey;

  /// No description provided for @shareInCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share in Community'**
  String get shareInCommunity;

  /// No description provided for @shareInCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Post survey to community feed'**
  String get shareInCommunityDesc;

  /// No description provided for @shareInChat.
  ///
  /// In en, this message translates to:
  /// **'Share in Chat'**
  String get shareInChat;

  /// No description provided for @shareInChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Share survey via direct message'**
  String get shareInChatDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @editSurvey.
  ///
  /// In en, this message translates to:
  /// **'Edit Survey'**
  String get editSurvey;

  /// No description provided for @surveyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Survey updated successfully'**
  String get surveyUpdated;

  /// No description provided for @surveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey Title'**
  String get surveyTitle;

  /// No description provided for @surveyTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter survey title...'**
  String get surveyTitleHint;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @enterQuestionText.
  ///
  /// In en, this message translates to:
  /// **'Enter question text...'**
  String get enterQuestionText;

  /// No description provided for @questionType.
  ///
  /// In en, this message translates to:
  /// **'Question Type'**
  String get questionType;

  /// No description provided for @singleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single Choice'**
  String get singleChoice;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @textAnswer.
  ///
  /// In en, this message translates to:
  /// **'Text Answer'**
  String get textAnswer;

  /// No description provided for @starRating.
  ///
  /// In en, this message translates to:
  /// **'Star Rating'**
  String get starRating;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// No description provided for @option.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get option;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @selectChat.
  ///
  /// In en, this message translates to:
  /// **'Select Chat'**
  String get selectChat;

  /// No description provided for @selectRecipient.
  ///
  /// In en, this message translates to:
  /// **'Select Recipient'**
  String get selectRecipient;

  /// No description provided for @surveySharedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Survey shared successfully'**
  String get surveySharedSuccessfully;

  /// No description provided for @connectWithPeopleFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect with people to share surveys'**
  String get connectWithPeopleFirst;

  /// No description provided for @tapToTakeSurvey.
  ///
  /// In en, this message translates to:
  /// **'Tap to participate in this survey'**
  String get tapToTakeSurvey;

  /// No description provided for @thankYouAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Thank you! You\'ve already completed this survey'**
  String get thankYouAlreadyCompleted;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @aiPoweredSurvey.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Survey'**
  String get aiPoweredSurvey;

  /// No description provided for @aiSurveyDescription.
  ///
  /// In en, this message translates to:
  /// **'Let AI generate professional survey questions based on your project'**
  String get aiSurveyDescription;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get selectTemplate;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get addDetails;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @chooseTemplateOrCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose a template or describe your own'**
  String get chooseTemplateOrCustom;

  /// No description provided for @describeWhatYouWant.
  ///
  /// In en, this message translates to:
  /// **'Tell AI what kind of questions you need'**
  String get describeWhatYouWant;

  /// No description provided for @proTip.
  ///
  /// In en, this message translates to:
  /// **'Pro Tip'**
  String get proTip;

  /// No description provided for @surveyTipContent.
  ///
  /// In en, this message translates to:
  /// **'Be specific about your goals. Mention target audience, key topics, and the type of feedback you\'re looking for.'**
  String get surveyTipContent;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @teamProgress.
  ///
  /// In en, this message translates to:
  /// **'Team Progress'**
  String get teamProgress;

  /// No description provided for @nearingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Nearing Deadlines'**
  String get nearingDeadlines;

  /// No description provided for @noNearingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'No tasks with approaching deadlines'**
  String get noNearingDeadlines;

  /// No description provided for @workloadBalance.
  ///
  /// In en, this message translates to:
  /// **'Workload Balance'**
  String get workloadBalance;

  /// No description provided for @workloadBalanced.
  ///
  /// In en, this message translates to:
  /// **'Workload is well balanced'**
  String get workloadBalanced;

  /// No description provided for @workloadUnbalanced.
  ///
  /// In en, this message translates to:
  /// **'Consider redistributing tasks'**
  String get workloadUnbalanced;

  /// No description provided for @milestoneOverview.
  ///
  /// In en, this message translates to:
  /// **'Milestone Overview'**
  String get milestoneOverview;

  /// No description provided for @activityFeed.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get activityFeed;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @atRiskStatus.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get atRiskStatus;

  /// No description provided for @overdueStatus.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueStatus;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} tasks'**
  String tasksCompleted(int completed, int total);

  /// No description provided for @taskCompletedActivity.
  ///
  /// In en, this message translates to:
  /// **'{userName} completed \"{taskName}\"'**
  String taskCompletedActivity(String userName, String taskName);

  /// No description provided for @taskStatusChangedActivity.
  ///
  /// In en, this message translates to:
  /// **'{userName} changed \"{taskName}\" to {status}'**
  String taskStatusChangedActivity(
    String userName,
    String taskName,
    String status,
  );

  /// No description provided for @taskAssignedActivity.
  ///
  /// In en, this message translates to:
  /// **'{taskName} assigned to {userName}'**
  String taskAssignedActivity(String taskName, String userName);

  /// No description provided for @idealDistribution.
  ///
  /// In en, this message translates to:
  /// **'Ideal: {count} tasks per member'**
  String idealDistribution(int count);

  /// No description provided for @teamManagementSection.
  ///
  /// In en, this message translates to:
  /// **'Team & Roles'**
  String get teamManagementSection;

  /// No description provided for @aiRoleSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Navi suggestion'**
  String get aiRoleSuggestion;

  /// No description provided for @currentRole.
  ///
  /// In en, this message translates to:
  /// **'Current: {role}'**
  String currentRole(String role);

  /// No description provided for @suggestedRole.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {role}'**
  String suggestedRole(String role);

  /// No description provided for @viewReasoning.
  ///
  /// In en, this message translates to:
  /// **'Long press to see why'**
  String get viewReasoning;

  /// No description provided for @naviReasoning.
  ///
  /// In en, this message translates to:
  /// **'Navi\'s Reasoning'**
  String get naviReasoning;

  /// No description provided for @missingRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing Roles'**
  String get missingRolesTitle;

  /// No description provided for @lookForSkills.
  ///
  /// In en, this message translates to:
  /// **'Look for someone with:'**
  String get lookForSkills;

  /// No description provided for @pendingInvitation.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingInvitation;

  /// No description provided for @analyzeTeam.
  ///
  /// In en, this message translates to:
  /// **'Analyze Team'**
  String get analyzeTeam;

  /// No description provided for @analyzingTeam.
  ///
  /// In en, this message translates to:
  /// **'Analyzing team with AI...'**
  String get analyzingTeam;

  /// No description provided for @noMissingRoles.
  ///
  /// In en, this message translates to:
  /// **'All roles are assigned!'**
  String get noMissingRoles;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get highPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get mediumPriority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get lowPriority;

  /// No description provided for @tasksRequiring.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks need this role'**
  String tasksRequiring(int count);

  /// No description provided for @skillLevel.
  ///
  /// In en, this message translates to:
  /// **'{skill} ({level})'**
  String skillLevel(String skill, String level);

  /// No description provided for @inviteNewMember.
  ///
  /// In en, this message translates to:
  /// **'Invite New Member'**
  String get inviteNewMember;

  /// No description provided for @connectWith.
  ///
  /// In en, this message translates to:
  /// **'Connect with {name}'**
  String connectWith(String name);

  /// No description provided for @addConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a personal message (optional)'**
  String get addConnectionMessage;

  /// No description provided for @connectionMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'d love to connect with you because...'**
  String get connectionMessageHint;

  /// No description provided for @sendConnection.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendConnection;

  /// No description provided for @findProjects.
  ///
  /// In en, this message translates to:
  /// **'Find Projects'**
  String get findProjects;

  /// No description provided for @applyToProject.
  ///
  /// In en, this message translates to:
  /// **'Apply to Project'**
  String get applyToProject;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @joinRequestMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you a good fit? (Optional)'**
  String get joinRequestMessageHint;

  /// No description provided for @sendApplication.
  ///
  /// In en, this message translates to:
  /// **'Send Application'**
  String get sendApplication;

  /// No description provided for @openRoles.
  ///
  /// In en, this message translates to:
  /// **'Open Roles'**
  String get openRoles;

  /// No description provided for @applicationSent.
  ///
  /// In en, this message translates to:
  /// **'Application sent successfully'**
  String get applicationSent;

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No Projects Found'**
  String get noListingsFound;

  /// No description provided for @noListingsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no open projects at the moment.'**
  String get noListingsFoundSubtitle;

  /// No description provided for @shareProject.
  ///
  /// In en, this message translates to:
  /// **'Share Project'**
  String get shareProject;

  /// No description provided for @leaderMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message to Applicants'**
  String get leaderMessageLabel;

  /// No description provided for @leaderMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for in team members? (Optional)'**
  String get leaderMessageHint;

  /// No description provided for @rolesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Roles Needed'**
  String get rolesNeeded;

  /// No description provided for @addRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Type a role and press enter (e.g., UI Designer)'**
  String get addRoleHint;

  /// No description provided for @addAtLeastOneRole.
  ///
  /// In en, this message translates to:
  /// **'Add at least one role to publish'**
  String get addAtLeastOneRole;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish Listing'**
  String get publishListing;

  /// No description provided for @unpublishListing.
  ///
  /// In en, this message translates to:
  /// **'Unpublish Listing'**
  String get unpublishListing;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptRequest;

  /// No description provided for @denyRequest.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get denyRequest;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join Requests'**
  String get joinRequests;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
