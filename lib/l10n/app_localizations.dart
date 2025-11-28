import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Risk Place'**
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

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone'**
  String get enterEmailOrPhone;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get enterPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to\n{email}'**
  String verificationCodeSent(String email);

  /// No description provided for @verificationCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your phone or email for the verification code'**
  String get verificationCodeMessage;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get enterCode;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @accountConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Account confirmed successfully!'**
  String get accountConfirmed;

  /// No description provided for @errorConfirmingCode.
  ///
  /// In en, this message translates to:
  /// **'Error confirming code'**
  String get errorConfirmingCode;

  /// No description provided for @codeResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code resent successfully!'**
  String get codeResentSuccess;

  /// No description provided for @codeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Code sent to email'**
  String get codeSentToEmail;

  /// No description provided for @smsFailed.
  ///
  /// In en, this message translates to:
  /// **'SMS failed. Check your email'**
  String get smsFailed;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {contact}'**
  String codeSentTo(String contact);

  /// No description provided for @errorResendingCode.
  ///
  /// In en, this message translates to:
  /// **'Error resending code'**
  String get errorResendingCode;

  /// No description provided for @verificationCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Request a new one.'**
  String get verificationCodeExpired;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please check and try again.'**
  String get invalidVerificationCode;

  /// No description provided for @failedToConfirmRegistration.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm registration'**
  String get failedToConfirmRegistration;

  /// No description provided for @verificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCodeTitle;

  /// No description provided for @verificationAttemptsLeft.
  ///
  /// In en, this message translates to:
  /// **'{attempts} attempts left'**
  String verificationAttemptsLeft(int attempts);

  /// No description provided for @verificationAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait {minutes} minutes'**
  String verificationAccountLocked(int minutes);

  /// No description provided for @verificationResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String verificationResendIn(int seconds);

  /// No description provided for @verificationCodeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {minutes}:{seconds}'**
  String verificationCodeExpiresIn(int minutes, String seconds);

  /// No description provided for @verificationWaitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} seconds before resending'**
  String verificationWaitBeforeResend(int seconds);

  /// No description provided for @verificationTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Wait 15 minutes'**
  String get verificationTooManyAttempts;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {contact}'**
  String verificationCodeSentTo(String contact);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check and try again.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your account is not verified. Please check your phone or email for the verification code.'**
  String get errorAccountNotVerified;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorNoPermission;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested information was not found.'**
  String get errorNotFound;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNoInternet;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The operation is taking too long. Check your connection and try again.'**
  String get errorTimeout;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Our servers are temporarily unavailable. Please try again shortly.'**
  String get errorServerUnavailable;

  /// No description provided for @errorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The data sent is invalid. Please check and try again.'**
  String get errorInvalidData;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorGeneric;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone to receive\nthe recovery code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @invalidIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or phone number'**
  String get invalidIdentifier;

  /// No description provided for @identifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Email or phone is required'**
  String get identifierRequired;

  /// No description provided for @codeSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent to your email!'**
  String get codeSentSuccess;

  /// No description provided for @errorSendingCode.
  ///
  /// In en, this message translates to:
  /// **'Error sending code'**
  String get errorSendingCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received and\nyour new password'**
  String get newPasswordSubtitle;

  /// No description provided for @verificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCodeLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccess;

  /// No description provided for @errorResettingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error resetting password'**
  String get errorResettingPassword;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterVerificationCode;

  /// No description provided for @codeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Code must have 6 digits'**
  String get codeMustBe6Digits;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password'**
  String get enterNewPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @safeRoute.
  ///
  /// In en, this message translates to:
  /// **'Safe Route'**
  String get safeRoute;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocation;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @myAlerts.
  ///
  /// In en, this message translates to:
  /// **'My Alerts'**
  String get myAlerts;

  /// No description provided for @reportRisk.
  ///
  /// In en, this message translates to:
  /// **'Report Risk'**
  String get reportRisk;

  /// No description provided for @riskTypes.
  ///
  /// In en, this message translates to:
  /// **'Risk Types'**
  String get riskTypes;

  /// Criminal occurrences
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get crime;

  /// Traffic accidents
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// Natural disasters
  ///
  /// In en, this message translates to:
  /// **'Natural Disaster'**
  String get naturalDisaster;

  /// Fire incidents
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get fire;

  /// Medical emergencies
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Infrastructure failures
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get infrastructure;

  /// Environmental risks
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// Violence and aggression
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get violence;

  /// Public safety issues
  ///
  /// In en, this message translates to:
  /// **'Public Safety'**
  String get publicSafety;

  /// Traffic problems
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get traffic;

  /// Urban problems
  ///
  /// In en, this message translates to:
  /// **'Urban Issue'**
  String get urbanIssue;

  /// Theft in residences, commerce or public
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get riskTopicRobber;

  /// Assault with violence, kidnapping or aggression
  ///
  /// In en, this message translates to:
  /// **'Assault'**
  String get riskTopicAssault;

  /// Theft without violence, such as bags or cell phones
  ///
  /// In en, this message translates to:
  /// **'Pickpocketing'**
  String get riskTopicTheft;

  /// Destruction of public or private property
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get riskTopicVandalism;

  /// Traffic accident involving vehicles or pedestrians
  ///
  /// In en, this message translates to:
  /// **'Traffic Accident'**
  String get riskTopicTrafficAccident;

  /// Accident in work environment or construction site
  ///
  /// In en, this message translates to:
  /// **'Work Accident'**
  String get riskTopicWorkAccident;

  /// Falls of people in public or private places
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get riskTopicFall;

  /// Urban or rural floods and inundations
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get riskTopicFlood;

  /// Landslides or cliff collapses
  ///
  /// In en, this message translates to:
  /// **'Landslide'**
  String get riskTopicLandslide;

  /// Strong storms, winds and lightning
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get riskTopicStorm;

  /// Fires in forest areas or savannas
  ///
  /// In en, this message translates to:
  /// **'Forest Fire'**
  String get riskTopicForestFire;

  /// Outbreaks of transmissible diseases
  ///
  /// In en, this message translates to:
  /// **'Infectious Disease'**
  String get riskTopicInfectiousDisease;

  /// Serious medical situations such as cardiac arrest
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get riskTopicMedicalEmergency;

  /// Collapse or problems on bridges and viaducts
  ///
  /// In en, this message translates to:
  /// **'Bridge Collapse'**
  String get riskTopicBridgeCollapse;

  /// Failures or interruption of electrical supply
  ///
  /// In en, this message translates to:
  /// **'Power Outage'**
  String get riskTopicPowerOutage;

  /// Air, water or soil pollution
  ///
  /// In en, this message translates to:
  /// **'Pollution'**
  String get riskTopicPollution;

  /// Leak of chemical or toxic products
  ///
  /// In en, this message translates to:
  /// **'Chemical Leak'**
  String get riskTopicChemicalLeak;

  /// No description provided for @assalto_mao_armada.
  ///
  /// In en, this message translates to:
  /// **'Armed Robbery'**
  String get assalto_mao_armada;

  /// No description provided for @roubo_residencia.
  ///
  /// In en, this message translates to:
  /// **'Residential Theft'**
  String get roubo_residencia;

  /// No description provided for @roubo_veiculo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Theft'**
  String get roubo_veiculo;

  /// No description provided for @furto_carteira.
  ///
  /// In en, this message translates to:
  /// **'Wallet Theft'**
  String get furto_carteira;

  /// No description provided for @furto_telemovel.
  ///
  /// In en, this message translates to:
  /// **'Phone Theft'**
  String get furto_telemovel;

  /// No description provided for @vandalismo.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get vandalismo;

  /// No description provided for @sequestro.
  ///
  /// In en, this message translates to:
  /// **'Kidnapping'**
  String get sequestro;

  /// No description provided for @violencia_domestica.
  ///
  /// In en, this message translates to:
  /// **'Domestic Violence'**
  String get violencia_domestica;

  /// No description provided for @agressao_fisica.
  ///
  /// In en, this message translates to:
  /// **'Physical Assault'**
  String get agressao_fisica;

  /// No description provided for @tiroteio.
  ///
  /// In en, this message translates to:
  /// **'Shooting'**
  String get tiroteio;

  /// No description provided for @acidente_viacao.
  ///
  /// In en, this message translates to:
  /// **'Car Accident'**
  String get acidente_viacao;

  /// No description provided for @colisao_transito.
  ///
  /// In en, this message translates to:
  /// **'Collision'**
  String get colisao_transito;

  /// No description provided for @atropelamento.
  ///
  /// In en, this message translates to:
  /// **'Pedestrian Hit'**
  String get atropelamento;

  /// No description provided for @capotamento.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Rollover'**
  String get capotamento;

  /// No description provided for @inundacao.
  ///
  /// In en, this message translates to:
  /// **'Flooding'**
  String get inundacao;

  /// No description provided for @deslizamento_terra.
  ///
  /// In en, this message translates to:
  /// **'Landslide'**
  String get deslizamento_terra;

  /// No description provided for @tempestade.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get tempestade;

  /// No description provided for @raio.
  ///
  /// In en, this message translates to:
  /// **'Lightning Strike'**
  String get raio;

  /// No description provided for @incendio_residencial.
  ///
  /// In en, this message translates to:
  /// **'Residential Fire'**
  String get incendio_residencial;

  /// No description provided for @incendio_comercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial Fire'**
  String get incendio_comercial;

  /// No description provided for @incendio_mercado.
  ///
  /// In en, this message translates to:
  /// **'Market Fire'**
  String get incendio_mercado;

  /// No description provided for @incendio_veiculo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Fire'**
  String get incendio_veiculo;

  /// No description provided for @emergencia_medica.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get emergencia_medica;

  /// No description provided for @impactArea.
  ///
  /// In en, this message translates to:
  /// **'Approximate impact area'**
  String get impactArea;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @detailedViewComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detailed view coming in next update'**
  String get detailedViewComingSoon;

  /// No description provided for @verifications.
  ///
  /// In en, this message translates to:
  /// **'Verifications'**
  String get verifications;

  /// No description provided for @rejections.
  ///
  /// In en, this message translates to:
  /// **'Rejections'**
  String get rejections;

  /// No description provided for @netScore.
  ///
  /// In en, this message translates to:
  /// **'Net Score'**
  String get netScore;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// No description provided for @riskType.
  ///
  /// In en, this message translates to:
  /// **'Risk Type'**
  String get riskType;

  /// No description provided for @riskTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get riskTopic;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @reportedAt.
  ///
  /// In en, this message translates to:
  /// **'Reported At'**
  String get reportedAt;

  /// No description provided for @relationFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get relationFamily;

  /// No description provided for @relationFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationFriend;

  /// No description provided for @relationColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get relationColleague;

  /// No description provided for @relationNeighbor.
  ///
  /// In en, this message translates to:
  /// **'Neighbor'**
  String get relationNeighbor;

  /// No description provided for @relationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationOther;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @sendSMS.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get sendSMS;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Settings'**
  String get errorLoadingSettings;

  /// No description provided for @noSettingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No settings available'**
  String get noSettingsAvailable;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires At'**
  String get expiresAt;

  /// No description provided for @surto_doenca.
  ///
  /// In en, this message translates to:
  /// **'Disease Outbreak'**
  String get surto_doenca;

  /// No description provided for @acidente_trabalho.
  ///
  /// In en, this message translates to:
  /// **'Work Accident'**
  String get acidente_trabalho;

  /// No description provided for @queda_energia.
  ///
  /// In en, this message translates to:
  /// **'Power Outage'**
  String get queda_energia;

  /// No description provided for @queda_agua.
  ///
  /// In en, this message translates to:
  /// **'Water Outage'**
  String get queda_agua;

  /// No description provided for @buraco_via.
  ///
  /// In en, this message translates to:
  /// **'Pothole'**
  String get buraco_via;

  /// No description provided for @semaforo_avariado.
  ///
  /// In en, this message translates to:
  /// **'Broken Traffic Light'**
  String get semaforo_avariado;

  /// No description provided for @cabo_solto.
  ///
  /// In en, this message translates to:
  /// **'Loose Cable'**
  String get cabo_solto;

  /// No description provided for @estrutura_risco.
  ///
  /// In en, this message translates to:
  /// **'Structure at Risk'**
  String get estrutura_risco;

  /// No description provided for @lixo_acumulado.
  ///
  /// In en, this message translates to:
  /// **'Garbage Accumulation'**
  String get lixo_acumulado;

  /// No description provided for @esgoto_aberto.
  ///
  /// In en, this message translates to:
  /// **'Open Sewage'**
  String get esgoto_aberto;

  /// No description provided for @poluicao_ar.
  ///
  /// In en, this message translates to:
  /// **'Air Pollution'**
  String get poluicao_ar;

  /// No description provided for @vazamento_agua.
  ///
  /// In en, this message translates to:
  /// **'Water Leak'**
  String get vazamento_agua;

  /// No description provided for @rua_escura.
  ///
  /// In en, this message translates to:
  /// **'Dark Street'**
  String get rua_escura;

  /// No description provided for @zona_assalto.
  ///
  /// In en, this message translates to:
  /// **'Robbery Zone'**
  String get zona_assalto;

  /// No description provided for @vigilancia_necessaria.
  ///
  /// In en, this message translates to:
  /// **'Police Needed'**
  String get vigilancia_necessaria;

  /// No description provided for @operacao_policial.
  ///
  /// In en, this message translates to:
  /// **'Police Operation'**
  String get operacao_policial;

  /// No description provided for @congestionamento.
  ///
  /// In en, this message translates to:
  /// **'Traffic Jam'**
  String get congestionamento;

  /// No description provided for @via_bloqueada.
  ///
  /// In en, this message translates to:
  /// **'Blocked Road'**
  String get via_bloqueada;

  /// No description provided for @manifestacao.
  ///
  /// In en, this message translates to:
  /// **'Protest'**
  String get manifestacao;

  /// No description provided for @animal_solto.
  ///
  /// In en, this message translates to:
  /// **'Loose Animal'**
  String get animal_solto;

  /// No description provided for @obra_sinalizacao.
  ///
  /// In en, this message translates to:
  /// **'Unsigned Construction'**
  String get obra_sinalizacao;

  /// No description provided for @assalto.
  ///
  /// In en, this message translates to:
  /// **'Robbery'**
  String get assalto;

  /// No description provided for @furtos.
  ///
  /// In en, this message translates to:
  /// **'Thefts'**
  String get furtos;

  /// No description provided for @roubo.
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get roubo;

  /// No description provided for @queda.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get queda;

  /// No description provided for @enchente.
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get enchente;

  /// No description provided for @deslizamento.
  ///
  /// In en, this message translates to:
  /// **'Landslide'**
  String get deslizamento;

  /// No description provided for @incendio_florestal.
  ///
  /// In en, this message translates to:
  /// **'Forest Fire'**
  String get incendio_florestal;

  /// No description provided for @doenca_infecciosa.
  ///
  /// In en, this message translates to:
  /// **'Infectious Disease'**
  String get doenca_infecciosa;

  /// No description provided for @queda_ponte.
  ///
  /// In en, this message translates to:
  /// **'Bridge Collapse'**
  String get queda_ponte;

  /// No description provided for @poluicao.
  ///
  /// In en, this message translates to:
  /// **'Pollution'**
  String get poluicao;

  /// No description provided for @vazamento_quimico.
  ///
  /// In en, this message translates to:
  /// **'Chemical Leak'**
  String get vazamento_quimico;

  /// No description provided for @acidente_transito.
  ///
  /// In en, this message translates to:
  /// **'Traffic Accident'**
  String get acidente_transito;

  /// No description provided for @searchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search Radius'**
  String get searchRadius;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlaces;

  /// No description provided for @savedPlacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access to your locations'**
  String get savedPlacesSubtitle;

  /// No description provided for @shareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share My Location'**
  String get shareMyLocation;

  /// No description provided for @shareMyLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send location to family & friends'**
  String get shareMyLocationSubtitle;

  /// No description provided for @checkSafeRoute.
  ///
  /// In en, this message translates to:
  /// **'Check Safe Route'**
  String get checkSafeRoute;

  /// No description provided for @checkSafeRouteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the safest path'**
  String get checkSafeRouteSubtitle;

  /// No description provided for @emergencyContactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manually dial local emergency numbers'**
  String get emergencyContactsSubtitle;

  /// No description provided for @editAlert.
  ///
  /// In en, this message translates to:
  /// **'Edit Alert'**
  String get editAlert;

  /// No description provided for @updateAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'Update the message, severity or radius of the alert.'**
  String get updateAlertMessage;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @describeTheAlert.
  ///
  /// In en, this message translates to:
  /// **'Describe the alert'**
  String get describeTheAlert;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageRequired;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @radiusMeters.
  ///
  /// In en, this message translates to:
  /// **'Radius (meters)'**
  String get radiusMeters;

  /// No description provided for @radiusRequired.
  ///
  /// In en, this message translates to:
  /// **'Radius is required'**
  String get radiusRequired;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// No description provided for @radiusMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Radius must be between 100 and 10,000m'**
  String get radiusMustBeBetween;

  /// No description provided for @changesWillBeApplied.
  ///
  /// In en, this message translates to:
  /// **'Changes will be applied immediately and subscribers will be notified.'**
  String get changesWillBeApplied;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @configureEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Configure an emergency contact to be notified in critical situations.'**
  String get configureEmergencyContact;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @exampleName.
  ///
  /// In en, this message translates to:
  /// **'Ex: Maria Silva'**
  String get exampleName;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @examplePhone.
  ///
  /// In en, this message translates to:
  /// **'Ex: +244 923 456 789'**
  String get examplePhone;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @priorityContact.
  ///
  /// In en, this message translates to:
  /// **'Priority contact'**
  String get priorityContact;

  /// No description provided for @willReceiveEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Will receive automatic emergency alerts'**
  String get willReceiveEmergencyAlerts;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @reportAtMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Report at my location'**
  String get reportAtMyLocation;

  /// No description provided for @useCurrentGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS location'**
  String get useCurrentGpsLocation;

  /// No description provided for @chooseLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose location on map'**
  String get chooseLocationOnMap;

  /// No description provided for @adjustManuallyOnMap.
  ///
  /// In en, this message translates to:
  /// **'Adjust manually on map'**
  String get adjustManuallyOnMap;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @createdByMe.
  ///
  /// In en, this message translates to:
  /// **'Created by Me'**
  String get createdByMe;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellation;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this alert?'**
  String get areYouSureDelete;

  /// No description provided for @areYouSureCancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel subscription to this alert?'**
  String get areYouSureCancelSubscription;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @alertRadius.
  ///
  /// In en, this message translates to:
  /// **'Alert Radius'**
  String get alertRadius;

  /// No description provided for @reportRadius.
  ///
  /// In en, this message translates to:
  /// **'Report Radius'**
  String get reportRadius;

  /// No description provided for @allReports.
  ///
  /// In en, this message translates to:
  /// **'All Reports'**
  String get allReports;

  /// No description provided for @errorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get errorLoadingReports;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on Map'**
  String get selectOnMap;

  /// No description provided for @confirmDestination.
  ///
  /// In en, this message translates to:
  /// **'Confirm Destination'**
  String get confirmDestination;

  /// No description provided for @removeContact.
  ///
  /// In en, this message translates to:
  /// **'Remove Contact'**
  String get removeContact;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @safetySettings.
  ///
  /// In en, this message translates to:
  /// **'Safety Settings'**
  String get safetySettings;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled'**
  String get notificationsEnabled;

  /// No description provided for @receiveAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive all notifications'**
  String get receiveAllNotifications;

  /// No description provided for @alertTypes.
  ///
  /// In en, this message translates to:
  /// **'Alert Types'**
  String get alertTypes;

  /// No description provided for @reportTypes.
  ///
  /// In en, this message translates to:
  /// **'Report Types'**
  String get reportTypes;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @shareLocationEmergencies.
  ///
  /// In en, this message translates to:
  /// **'Share location in emergencies'**
  String get shareLocationEmergencies;

  /// No description provided for @locationHistory.
  ///
  /// In en, this message translates to:
  /// **'Location History'**
  String get locationHistory;

  /// No description provided for @saveLocationHistory.
  ///
  /// In en, this message translates to:
  /// **'Save history of where you\'ve been'**
  String get saveLocationHistory;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @anonymousReports.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Reports'**
  String get anonymousReports;

  /// No description provided for @dontShowNameReports.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show your name on reports'**
  String get dontShowNameReports;

  /// No description provided for @showOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Show Online Status'**
  String get showOnlineStatus;

  /// No description provided for @othersCanSeeOnline.
  ///
  /// In en, this message translates to:
  /// **'Others can see if you\'re online'**
  String get othersCanSeeOnline;

  /// No description provided for @automaticAlerts.
  ///
  /// In en, this message translates to:
  /// **'Automatic Alerts'**
  String get automaticAlerts;

  /// No description provided for @enableSmartAutomaticAlerts.
  ///
  /// In en, this message translates to:
  /// **'Enable smart automatic alerts'**
  String get enableSmartAutomaticAlerts;

  /// No description provided for @dangerZones.
  ///
  /// In en, this message translates to:
  /// **'Danger Zones'**
  String get dangerZones;

  /// No description provided for @alertWhenEnteringRiskAreas.
  ///
  /// In en, this message translates to:
  /// **'Alert when entering risk areas'**
  String get alertWhenEnteringRiskAreas;

  /// No description provided for @timeBasedAlerts.
  ///
  /// In en, this message translates to:
  /// **'Time-based Alerts'**
  String get timeBasedAlerts;

  /// No description provided for @specialAlertsRiskTimes.
  ///
  /// In en, this message translates to:
  /// **'Special alerts during risk times'**
  String get specialAlertsRiskTimes;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @automaticNightMode.
  ///
  /// In en, this message translates to:
  /// **'Automatic Night Mode'**
  String get automaticNightMode;

  /// No description provided for @enableAutomaticallyAtNight.
  ///
  /// In en, this message translates to:
  /// **'Enable automatically at night'**
  String get enableAutomaticallyAtNight;

  /// No description provided for @nightModeStart.
  ///
  /// In en, this message translates to:
  /// **'Night Mode Start'**
  String get nightModeStart;

  /// No description provided for @nightModeEnd.
  ///
  /// In en, this message translates to:
  /// **'Night Mode End'**
  String get nightModeEnd;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get moreDetails;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @deletePlace.
  ///
  /// In en, this message translates to:
  /// **'Delete Place'**
  String get deletePlace;

  /// No description provided for @sharingLocation.
  ///
  /// In en, this message translates to:
  /// **'Sharing Location'**
  String get sharingLocation;

  /// No description provided for @stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopSharing;

  /// No description provided for @stopSharingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopSharingConfirm;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Place Name'**
  String get placeName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @describeAlert.
  ///
  /// In en, this message translates to:
  /// **'Describe the alert'**
  String get describeAlert;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @markAsPriority.
  ///
  /// In en, this message translates to:
  /// **'Mark as priority'**
  String get markAsPriority;

  /// No description provided for @receiveAutomaticEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive automatic emergency alerts'**
  String get receiveAutomaticEmergencyAlerts;

  /// No description provided for @rangeOfReach.
  ///
  /// In en, this message translates to:
  /// **'Range of Reach'**
  String get rangeOfReach;

  /// No description provided for @emergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'🚨 EMERGENCY ALERT'**
  String get emergencyAlert;

  /// No description provided for @reachRadius.
  ///
  /// In en, this message translates to:
  /// **'Reach Radius'**
  String get reachRadius;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @communityReport.
  ///
  /// In en, this message translates to:
  /// **'📍 COMMUNITY REPORT'**
  String get communityReport;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @automaticAlertsSettings.
  ///
  /// In en, this message translates to:
  /// **'Automatic Alerts'**
  String get automaticAlertsSettings;

  /// No description provided for @nightMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get nightMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fillDataBelow.
  ///
  /// In en, this message translates to:
  /// **'Fill in the data below'**
  String get fillDataBelow;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @enterFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNamePlaceholder;

  /// No description provided for @enterEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmailPlaceholder;

  /// No description provided for @enterPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get enterPhonePlaceholder;

  /// No description provided for @enterPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPasswordPlaceholder;

  /// No description provided for @iAmRFCE.
  ///
  /// In en, this message translates to:
  /// **'I am RFCE'**
  String get iAmRFCE;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountQuestion;

  /// No description provided for @sentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to\n{email}'**
  String sentCodeTo(Object email);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @whatDoYouSee.
  ///
  /// In en, this message translates to:
  /// **'What do you see?'**
  String get whatDoYouSee;

  /// No description provided for @selectSpecificType.
  ///
  /// In en, this message translates to:
  /// **'Select specific type'**
  String get selectSpecificType;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String helloUser(Object name);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @welcomeNeter.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Neter!'**
  String get welcomeNeter;

  /// No description provided for @loginOrRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginOrRegister;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @viewAlertsPostedOrSubscribed.
  ///
  /// In en, this message translates to:
  /// **'View alerts you posted or subscribed to'**
  String get viewAlertsPostedOrSubscribed;

  /// No description provided for @viewAllSystemReports.
  ///
  /// In en, this message translates to:
  /// **'View all system reports'**
  String get viewAllSystemReports;

  /// No description provided for @emergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContactsTitle;

  /// No description provided for @manageTrustedContacts.
  ///
  /// In en, this message translates to:
  /// **'Manage trusted contacts'**
  String get manageTrustedContacts;

  /// No description provided for @safetySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Settings'**
  String get safetySettingsTitle;

  /// No description provided for @notificationsTrackingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Notifications, tracking, privacy'**
  String get notificationsTrackingPrivacy;

  /// No description provided for @communityFeedback.
  ///
  /// In en, this message translates to:
  /// **'Community & Feedback'**
  String get communityFeedback;

  /// No description provided for @sendFeedbackReadUpdates.
  ///
  /// In en, this message translates to:
  /// **'Send feedback or read updates'**
  String get sendFeedbackReadUpdates;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editPersonalInfoPreferences.
  ///
  /// In en, this message translates to:
  /// **'Edit personal info & preferences'**
  String get editPersonalInfoPreferences;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @receiveUrgentSafetyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive urgent safety alerts in real-time'**
  String get receiveUrgentSafetyAlerts;

  /// No description provided for @turnOnNow.
  ///
  /// In en, this message translates to:
  /// **'Turn on now'**
  String get turnOnNow;

  /// No description provided for @notInformed.
  ///
  /// In en, this message translates to:
  /// **'Not informed'**
  String get notInformed;

  /// No description provided for @helloNeter.
  ///
  /// In en, this message translates to:
  /// **'Hello, Neter!'**
  String get helloNeter;

  /// No description provided for @exploringAsVisitor.
  ///
  /// In en, this message translates to:
  /// **'You\'re exploring as a visitor'**
  String get exploringAsVisitor;

  /// No description provided for @anonymousMode.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Mode'**
  String get anonymousMode;

  /// No description provided for @asNeterYouCan.
  ///
  /// In en, this message translates to:
  /// **'As a Neter, you can:'**
  String get asNeterYouCan;

  /// No description provided for @viewNearbyAlerts.
  ///
  /// In en, this message translates to:
  /// **'View nearby alerts'**
  String get viewNearbyAlerts;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get receiveNotifications;

  /// No description provided for @createAccountToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Create an account to unlock:'**
  String get createAccountToUnlock;

  /// No description provided for @reportAlerts.
  ///
  /// In en, this message translates to:
  /// **'Report alerts'**
  String get reportAlerts;

  /// No description provided for @commentAndInteract.
  ///
  /// In en, this message translates to:
  /// **'Comment and interact'**
  String get commentAndInteract;

  /// No description provided for @customizeProfile.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile'**
  String get customizeProfile;

  /// No description provided for @createAccountOrLogin.
  ///
  /// In en, this message translates to:
  /// **'Create Account / Login'**
  String get createAccountOrLogin;

  /// No description provided for @joinNeterCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Neter community!'**
  String get joinNeterCommunity;

  /// No description provided for @voteConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Thank you for confirming!'**
  String get voteConfirmed;

  /// No description provided for @voteFeedbackReceived.
  ///
  /// In en, this message translates to:
  /// **'Feedback received'**
  String get voteFeedbackReceived;

  /// No description provided for @voteErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to vote'**
  String get voteErrorTitle;

  /// No description provided for @voteErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process your vote. Please try again.'**
  String get voteErrorMessage;

  /// No description provided for @voteErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet and try again.'**
  String get voteErrorNetwork;

  /// No description provided for @voteErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get voteErrorServer;

  /// No description provided for @voteErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to vote.'**
  String get voteErrorUnauthorized;

  /// No description provided for @setHome.
  ///
  /// In en, this message translates to:
  /// **'Set Home'**
  String get setHome;

  /// No description provided for @setWork.
  ///
  /// In en, this message translates to:
  /// **'Set Work'**
  String get setWork;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get searchAddress;

  /// No description provided for @errorSearchingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error searching address'**
  String get errorSearchingAddress;

  /// No description provided for @pleaseSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select an address'**
  String get pleaseSelectAddress;

  /// No description provided for @errorSavingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error saving address: {error}'**
  String errorSavingAddress(Object error);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {address}'**
  String selected(Object address);

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields!'**
  String get fillAllFields;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful!'**
  String get loginSuccessful;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedBadge;

  /// No description provided for @unreliableBadge.
  ///
  /// In en, this message translates to:
  /// **'Unreliable'**
  String get unreliableBadge;

  /// No description provided for @confirmsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} confirm'**
  String confirmsBadge(Object count);

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @unsubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribeButton;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @confirmDestinationButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Destination'**
  String get confirmDestinationButton;

  /// No description provided for @errorCalculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Error calculating route'**
  String get errorCalculatingRoute;

  /// No description provided for @errorSendingSMS.
  ///
  /// In en, this message translates to:
  /// **'Error sending SMS: {error}'**
  String errorSendingSMS(Object error);

  /// No description provided for @errorRegisterCheckCredentials.
  ///
  /// In en, this message translates to:
  /// **'Error registering. Check your credentials.'**
  String get errorRegisterCheckCredentials;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get couldNotGetLocation;

  /// No description provided for @locationStreamError.
  ///
  /// In en, this message translates to:
  /// **'Location stream error: {error}'**
  String locationStreamError(Object error);

  /// No description provided for @addSafePlace.
  ///
  /// In en, this message translates to:
  /// **'Add Safe Place'**
  String get addSafePlace;

  /// No description provided for @safeRouteButton.
  ///
  /// In en, this message translates to:
  /// **'Safe Route'**
  String get safeRouteButton;

  /// No description provided for @waitingLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting location...'**
  String get waitingLocation;

  /// No description provided for @waitingGPS.
  ///
  /// In en, this message translates to:
  /// **'Waiting GPS location...'**
  String get waitingGPS;

  /// No description provided for @homeAddressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Home address saved successfully!'**
  String get homeAddressSavedSuccess;

  /// No description provided for @workAddressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Work address saved successfully!'**
  String get workAddressSavedSuccess;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully!'**
  String addedSuccessfully(Object name);

  /// No description provided for @allReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Reports'**
  String get allReportsTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by:'**
  String get filterBy;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @loadingReports.
  ///
  /// In en, this message translates to:
  /// **'Loading reports...'**
  String get loadingReports;

  /// No description provided for @loadingRiskTypes.
  ///
  /// In en, this message translates to:
  /// **'Preparing report options...'**
  String get loadingRiskTypes;

  /// No description provided for @loadingRiskTypesMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading available risk categories, please wait a moment.'**
  String get loadingRiskTypesMessage;

  /// No description provided for @errorLoadingRiskTypes.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Options'**
  String get errorLoadingRiskTypes;

  /// No description provided for @errorLoadingRiskTypesMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the report categories. This may be due to a slow connection or server issue.'**
  String get errorLoadingRiskTypesMessage;

  /// No description provided for @apiSlowWarning.
  ///
  /// In en, this message translates to:
  /// **'API may be slow, please wait...'**
  String get apiSlowWarning;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request Timeout'**
  String get timeoutError;

  /// No description provided for @timeoutErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. This may be due to slow API or poor internet connection.'**
  String get timeoutErrorMessage;

  /// No description provided for @timeoutTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Check your internet connection or try again in a few moments.'**
  String get timeoutTip;

  /// No description provided for @totalReports.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} reports'**
  String totalReports(Object count);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @shareLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocationTitle;

  /// No description provided for @shareLocationQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to share?'**
  String get shareLocationQuestion;

  /// No description provided for @minutes15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get minutes15;

  /// No description provided for @minutes30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get minutes30;

  /// No description provided for @minutes60.
  ///
  /// In en, this message translates to:
  /// **'60 minutes'**
  String get minutes60;

  /// No description provided for @shortSharing.
  ///
  /// In en, this message translates to:
  /// **'Short sharing'**
  String get shortSharing;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @longSharing.
  ///
  /// In en, this message translates to:
  /// **'Long sharing'**
  String get longSharing;

  /// No description provided for @sharingLocationActive.
  ///
  /// In en, this message translates to:
  /// **'Sharing Location'**
  String get sharingLocationActive;

  /// No description provided for @activeSharing.
  ///
  /// In en, this message translates to:
  /// **'Active Sharing'**
  String get activeSharing;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in: {time}'**
  String expiresIn(Object time);

  /// No description provided for @stopSharingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to stop sharing your location?'**
  String get stopSharingQuestion;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @locationUpdating.
  ///
  /// In en, this message translates to:
  /// **'Your location is being updated every 10 seconds'**
  String get locationUpdating;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'I\'m sharing my real-time location with you.\n\nAccess: {link}\n\nValid until: {expires}\n\nRiskPlace - Safer Cities 🛡️'**
  String shareMessage(Object expires, Object link);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon. Stay tuned for updates!'**
  String get featureComingSoon;

  /// No description provided for @settingsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Setting updated successfully'**
  String get settingsUpdatedSuccess;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// No description provided for @alertTypeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get alertTypeLow;

  /// No description provided for @alertTypeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get alertTypeMedium;

  /// No description provided for @alertTypeHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get alertTypeHigh;

  /// No description provided for @alertTypeCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get alertTypeCritical;

  /// No description provided for @reportTypeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get reportTypeRejected;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
