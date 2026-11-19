import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabCommittee.
  ///
  /// In en, this message translates to:
  /// **'Committee'**
  String get tabCommittee;

  /// No description provided for @tabFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get tabFaq;

  /// No description provided for @tabContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get tabContacts;

  /// No description provided for @tabMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get tabMember;

  /// No description provided for @assalamu.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaykum'**
  String get assalamu;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @inTime.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inTime;

  /// No description provided for @allTimes.
  ///
  /// In en, this message translates to:
  /// **'All prayer times'**
  String get allTimes;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNews;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get urgent;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayerTimes;

  /// No description provided for @ramadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadan;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @centenary.
  ///
  /// In en, this message translates to:
  /// **'Centenary'**
  String get centenary;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duas;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @adhanAlert.
  ///
  /// In en, this message translates to:
  /// **'Adhan alert'**
  String get adhanAlert;

  /// No description provided for @prayerMethod.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League · Hanafi Asr · Port Louis'**
  String get prayerMethod;

  /// No description provided for @ramadanBegins.
  ///
  /// In en, this message translates to:
  /// **'Ramadan begins in'**
  String get ramadanBegins;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @dayOf.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayOf;

  /// No description provided for @suhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends'**
  String get suhoor;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @sightingNote.
  ///
  /// In en, this message translates to:
  /// **'Dates are calculated and confirmed by moon sighting.'**
  String get sightingNote;

  /// No description provided for @timetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetable;

  /// No description provided for @qiblaHint.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone flat and turn until the arrow points up.'**
  String get qiblaHint;

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'Facing the Qibla'**
  String get qiblaAligned;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'Bearing from Port Louis'**
  String get qiblaBearing;

  /// No description provided for @qiblaNoSensor.
  ///
  /// In en, this message translates to:
  /// **'Compass unavailable on this device. Use the bearing below.'**
  String get qiblaNoSensor;

  /// No description provided for @committeeSub.
  ///
  /// In en, this message translates to:
  /// **'2025–2027 term · {count} members'**
  String committeeSub(int count);

  /// No description provided for @searchQuestions.
  ///
  /// In en, this message translates to:
  /// **'Search questions'**
  String get searchQuestions;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching questions.'**
  String get noResults;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get directions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get followUs;

  /// No description provided for @officeHours.
  ///
  /// In en, this message translates to:
  /// **'Office hours'**
  String get officeHours;

  /// No description provided for @memberLogin.
  ///
  /// In en, this message translates to:
  /// **'Member login'**
  String get memberLogin;

  /// No description provided for @loginSub.
  ///
  /// In en, this message translates to:
  /// **'Access your subscription, payments and receipts.'**
  String get loginSub;

  /// No description provided for @emailOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Email or member number'**
  String get emailOrNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot;

  /// No description provided for @requestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get requestAccess;

  /// No description provided for @notMember.
  ///
  /// In en, this message translates to:
  /// **'New to the app?'**
  String get notMember;

  /// No description provided for @accessNote.
  ///
  /// In en, this message translates to:
  /// **'Access is granted after the committee approves your request.'**
  String get accessNote;

  /// No description provided for @unlockBio.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockBio;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @bioFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric check cancelled.'**
  String get bioFailed;

  /// No description provided for @requestSub.
  ///
  /// In en, this message translates to:
  /// **'We match your details with the society register.'**
  String get requestSub;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nic.
  ///
  /// In en, this message translates to:
  /// **'NIC number'**
  String get nic;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobile;

  /// No description provided for @memberNo.
  ///
  /// In en, this message translates to:
  /// **'Member number (if known)'**
  String get memberNo;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'I consent to CHI processing my data under the Data Protection Act 2017.'**
  String get consent;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submit;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request received'**
  String get requestSent;

  /// No description provided for @requestSentBody.
  ///
  /// In en, this message translates to:
  /// **'The secretary will review it shortly. You will be notified by SMS and email.'**
  String get requestSentBody;

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get errName;

  /// No description provided for @errNic.
  ///
  /// In en, this message translates to:
  /// **'NIC: 1 letter + 13 characters'**
  String get errNic;

  /// No description provided for @errMobile.
  ///
  /// In en, this message translates to:
  /// **'Mauritian mobile: 8 digits starting with 5'**
  String get errMobile;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errEmail;

  /// No description provided for @errConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent is required'**
  String get errConsent;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @paidUpTo.
  ///
  /// In en, this message translates to:
  /// **'Paid up to'**
  String get paidUpTo;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get nextDue;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @payMonths.
  ///
  /// In en, this message translates to:
  /// **'Pay upcoming months'**
  String get payMonths;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Our history'**
  String get history;

  /// No description provided for @wholeRupees.
  ///
  /// In en, this message translates to:
  /// **'Whole rupees only, e.g. 1250'**
  String get wholeRupees;

  /// No description provided for @offlinePay.
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Connect to the internet to pay; nothing is charged or saved for later.'**
  String get offlinePay;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'We’ll send your request to the society’s Data Protection officer, who will contact you to confirm it.'**
  String get deleteConfirm;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Not found in the society register'**
  String get rejectReason;

  /// No description provided for @rejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}’s request?'**
  String rejectTitle(String name);

  /// No description provided for @callOrWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Call or WhatsApp'**
  String get callOrWhatsapp;

  /// No description provided for @openUntil.
  ///
  /// In en, this message translates to:
  /// **'Open now · until {time}'**
  String openUntil(String time);

  /// No description provided for @opensAt.
  ///
  /// In en, this message translates to:
  /// **'Closed · opens {when}'**
  String opensAt(String when);

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history & receipts'**
  String get paymentHistory;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get profile;

  /// No description provided for @arrears.
  ///
  /// In en, this message translates to:
  /// **'Arrears'**
  String get arrears;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get youOwe;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All paid up'**
  String get allClear;

  /// No description provided for @bioPrompt.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to unlock next time'**
  String get bioPrompt;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @paySub.
  ///
  /// In en, this message translates to:
  /// **'Arrears are included automatically.'**
  String get paySub;

  /// No description provided for @selectMonths.
  ///
  /// In en, this message translates to:
  /// **'Select months'**
  String get selectMonths;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @monthsSelected.
  ///
  /// In en, this message translates to:
  /// **'months selected'**
  String get monthsSelected;

  /// No description provided for @payWithJuice.
  ///
  /// In en, this message translates to:
  /// **'Pay with Juice'**
  String get payWithJuice;

  /// No description provided for @redirectNote.
  ///
  /// In en, this message translates to:
  /// **'You will confirm the payment in Juice by MCB.'**
  String get redirectNote;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Juice checkout'**
  String get checkout;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @sandbox.
  ///
  /// In en, this message translates to:
  /// **'Sandbox · simulated'**
  String get sandbox;

  /// No description provided for @outcome.
  ///
  /// In en, this message translates to:
  /// **'Sandbox outcome'**
  String get outcome;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @stepAuth.
  ///
  /// In en, this message translates to:
  /// **'Authorise in Juice'**
  String get stepAuth;

  /// No description provided for @stepServer.
  ///
  /// In en, this message translates to:
  /// **'Server confirms with MCB'**
  String get stepServer;

  /// No description provided for @stepReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt issued'**
  String get stepReceipt;

  /// No description provided for @confirmPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPay;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Payment declined'**
  String get declined;

  /// No description provided for @declinedBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing was charged. You can try again.'**
  String get declinedBody;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @donationReceived.
  ///
  /// In en, this message translates to:
  /// **'Donation received'**
  String get donationReceived;

  /// No description provided for @receiptNo.
  ///
  /// In en, this message translates to:
  /// **'Receipt no.'**
  String get receiptNo;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download receipt (PDF)'**
  String get downloadReceipt;

  /// No description provided for @backToAccount.
  ///
  /// In en, this message translates to:
  /// **'Back to my account'**
  String get backToAccount;

  /// No description provided for @emailCopy.
  ///
  /// In en, this message translates to:
  /// **'A copy has been sent to'**
  String get emailCopy;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometrics;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders'**
  String get reminders;

  /// No description provided for @remindersSub.
  ///
  /// In en, this message translates to:
  /// **'3 days before and after each due date'**
  String get remindersSub;

  /// No description provided for @adminPreview.
  ///
  /// In en, this message translates to:
  /// **'Committee admin preview'**
  String get adminPreview;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Request data deletion'**
  String get deleteData;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personal;

  /// No description provided for @deleteSent.
  ///
  /// In en, this message translates to:
  /// **'Deletion request sent to the Data Protection officer.'**
  String get deleteSent;

  /// No description provided for @donateSub.
  ///
  /// In en, this message translates to:
  /// **'Paid through Juice, receipted separately from subscriptions.'**
  String get donateSub;

  /// No description provided for @fund.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get fund;

  /// No description provided for @donateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate with Juice'**
  String get donateNow;

  /// No description provided for @going.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get going;

  /// No description provided for @rsvp.
  ///
  /// In en, this message translates to:
  /// **'RSVP'**
  String get rsvp;

  /// No description provided for @membersOnly.
  ///
  /// In en, this message translates to:
  /// **'Members only'**
  String get membersOnly;

  /// No description provided for @loginToView.
  ///
  /// In en, this message translates to:
  /// **'Log in to open member documents.'**
  String get loginToView;

  /// No description provided for @docPreview.
  ///
  /// In en, this message translates to:
  /// **'Opens the PDF in the live app.'**
  String get docPreview;

  /// No description provided for @centenarySub.
  ///
  /// In en, this message translates to:
  /// **'A century of community, 1927–2027'**
  String get centenarySub;

  /// No description provided for @programme.
  ///
  /// In en, this message translates to:
  /// **'Centenary programme'**
  String get programme;

  /// No description provided for @sample.
  ///
  /// In en, this message translates to:
  /// **'Sample content · CHI to supply'**
  String get sample;

  /// No description provided for @adminSub.
  ///
  /// In en, this message translates to:
  /// **'Web admin panel · mobile preview'**
  String get adminSub;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active members'**
  String get activeMembers;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected this month'**
  String get collected;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get pendingRequests;

  /// No description provided for @accessRequests.
  ///
  /// In en, this message translates to:
  /// **'Access requests'**
  String get accessRequests;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match found'**
  String get noMatch;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @nothingPending.
  ///
  /// In en, this message translates to:
  /// **'No requests waiting.'**
  String get nothingPending;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @articleGone.
  ///
  /// In en, this message translates to:
  /// **'This article is no longer available.'**
  String get articleGone;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found.'**
  String get receiptNotFound;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'A one-time reset code is sent by email or SMS.'**
  String get forgotBody;

  /// No description provided for @committeeConsent.
  ///
  /// In en, this message translates to:
  /// **'Contact details are shown only where the committee member has consented.'**
  String get committeeConsent;

  /// No description provided for @nicNote.
  ///
  /// In en, this message translates to:
  /// **'NIC numbers are encrypted at rest and only visible to the secretary.'**
  String get nicNote;

  /// No description provided for @invalidPayment.
  ///
  /// In en, this message translates to:
  /// **'Invalid payment request.'**
  String get invalidPayment;

  /// No description provided for @pdfError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF. Please try again.'**
  String get pdfError;

  /// No description provided for @bioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get bioUnavailable;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @biometricsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometricsGeneric;

  /// No description provided for @demoBuild.
  ///
  /// In en, this message translates to:
  /// **'CHI app · demo build 0.2'**
  String get demoBuild;

  /// No description provided for @centenaryTagline.
  ///
  /// In en, this message translates to:
  /// **'One hundred years of faith, learning and service in Port Louis.'**
  String get centenaryTagline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. receipt'**
  String get searchHint;

  /// No description provided for @kindNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get kindNews;

  /// No description provided for @kindNotice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get kindNotice;

  /// No description provided for @kindJanaza.
  ///
  /// In en, this message translates to:
  /// **'Janaza'**
  String get kindJanaza;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @methodJuice.
  ///
  /// In en, this message translates to:
  /// **'Juice by MCB'**
  String get methodJuice;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash (manual entry)'**
  String get methodCash;

  /// No description provided for @methodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer (manual entry)'**
  String get methodBank;

  /// No description provided for @donateDetail.
  ///
  /// In en, this message translates to:
  /// **'Zakat, sadaqah and the mosque fund'**
  String get donateDetail;

  /// No description provided for @centenaryDetail.
  ///
  /// In en, this message translates to:
  /// **'A hundred years in 2027'**
  String get centenaryDetail;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @inactiveNote.
  ///
  /// In en, this message translates to:
  /// **'Your membership is inactive. Please contact the society to settle your balance.'**
  String get inactiveNote;

  /// No description provided for @manualMethod.
  ///
  /// In en, this message translates to:
  /// **'Manual · {method}'**
  String manualMethod(String method);

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photoCredits.
  ///
  /// In en, this message translates to:
  /// **'Photo credits'**
  String get photoCredits;

  /// No description provided for @photoCreditsSub.
  ///
  /// In en, this message translates to:
  /// **'Placeholder photography until CHI supplies its own. All images from Wikimedia Commons.'**
  String get photoCreditsSub;

  /// No description provided for @visitUs.
  ///
  /// In en, this message translates to:
  /// **'Visit us'**
  String get visitUs;

  /// No description provided for @eventsSub.
  ///
  /// In en, this message translates to:
  /// **'Lectures, gatherings and community days'**
  String get eventsSub;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
