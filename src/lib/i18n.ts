/**
 * UI strings, externalised for translation (NFR-07). English and French at launch;
 * Kreol Morisien slots in as a third key without code changes.
 */
export type Lang = 'en' | 'fr';
export type Localized = Record<Lang, string>;

const en = {
  // tabs
  tabHome: 'Home', tabCommittee: 'Committee', tabFaq: 'FAQ', tabContacts: 'Contacts', tabMember: 'Member',
  // home
  assalamu: 'Assalamu alaykum', nextPrayer: 'Next prayer', inTime: 'in', allTimes: 'All prayer times',
  explore: 'Explore', latestNews: 'Latest news', seeAll: 'See all', urgent: 'Notice',
  prayerTimes: 'Prayer times', ramadan: 'Ramadan', qibla: 'Qibla', events: 'Events', donate: 'Donate',
  documents: 'Documents', centenary: 'Centenary', duas: 'Duas', notifications: 'Notifications',
  // prayers
  fajr: 'Fajr', sunrise: 'Sunrise', dhuhr: 'Dhuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha',
  adhanAlert: 'Adhan alert', prayerMethod: 'Muslim World League · Hanafi Asr · Port Louis',
  // ramadan
  ramadanBegins: 'Ramadan begins in', days: 'days', dayOf: 'Day', suhoor: 'Suhoor ends', iftar: 'Iftar',
  sightingNote: 'Dates are calculated and confirmed by moon sighting.', timetable: 'Timetable',
  // qibla
  qiblaHint: 'Hold your phone flat and turn until the arrow points up.', qiblaAligned: 'Facing the Qibla',
  qiblaBearing: 'Bearing from Port Louis', qiblaNoSensor: 'Compass unavailable on this device. Use the bearing below.',
  // committee / faq / contacts
  committeeSub: 'Management committee 2025–2027', faqSub: 'Answers to common questions',
  searchQuestions: 'Search questions', noResults: 'No matching questions.', all: 'All',
  contactsSub: 'Visit, call or write to us', directions: 'Get directions', call: 'Call', email: 'Email',
  whatsapp: 'WhatsApp', followUs: 'Follow us', officeHours: 'Office hours',
  // auth
  memberLogin: 'Member login', loginSub: 'Access your subscription, payments and receipts.',
  emailOrNumber: 'Email or member number', password: 'Password', logIn: 'Log in',
  forgot: 'Forgot password?', requestAccess: 'Request access', notMember: 'New to the app?',
  accessNote: 'Access is granted after the committee approves your request.',
  unlockBio: 'Unlock with biometrics', welcomeBack: 'Welcome back', bioFailed: 'Biometric check cancelled.',
  // request access
  requestSub: 'We match your details with the society register.', fullName: 'Full name',
  nic: 'NIC number', mobile: 'Mobile number', memberNo: 'Member number (if known)',
  consent: 'I consent to CHI processing my data under the Data Protection Act 2017.',
  submit: 'Submit request', requestSent: 'Request received',
  requestSentBody: 'The secretary will review it shortly. You will be notified by SMS and email.',
  errName: 'Enter your full name', errNic: 'NIC: 1 letter + 13 characters', errMobile: 'Mauritian mobile: 8 digits starting with 5',
  errEmail: 'Enter a valid email', errConsent: 'Consent is required', done: 'Done',
  // member
  myAccount: 'My account', paidUpTo: 'Paid up to', nextDue: 'Next due', active: 'Active',
  overdue: 'Overdue', due: 'Due', paid: 'Paid', upcoming: 'Upcoming', subscription: 'Subscription',
  payMonths: 'Pay upcoming months', history: 'Payment history & receipts', profile: 'Profile & settings',
  arrears: 'Arrears', category: 'Category', memberSince: 'Member since', youOwe: 'Outstanding',
  allClear: 'All paid up', bioPrompt: 'Use biometrics to unlock next time', enable: 'Enable',
  // pay
  paySub: 'Arrears are included automatically.', selectMonths: 'Select months', total: 'Total',
  monthsSelected: 'months selected', payWithJuice: 'Pay with Juice', redirectNote: 'You will confirm the payment in Juice by MCB.',
  // checkout
  checkout: 'Juice checkout', merchant: 'Merchant', amount: 'Amount', reference: 'Reference',
  sandbox: 'Sandbox · simulated', outcome: 'Sandbox outcome', approve: 'Approve', decline: 'Decline',
  stepAuth: 'Authorise in Juice', stepServer: 'Server confirms with MCB', stepReceipt: 'Receipt issued',
  confirmPay: 'Confirm payment', declined: 'Payment declined', declinedBody: 'Nothing was charged. You can try again.',
  tryAgain: 'Try again', cancel: 'Cancel',
  // receipt
  paymentSuccessful: 'Payment successful', donationReceived: 'Donation received', receiptNo: 'Receipt no.',
  months: 'Months', date: 'Date', method: 'Method', downloadReceipt: 'Download receipt (PDF)',
  backToAccount: 'Back to my account', emailCopy: 'A copy has been sent to', manual: 'Manual',
  // profile
  language: 'Language', biometrics: 'Biometric unlock', reminders: 'Payment reminders',
  remindersSub: '3 days before and after each due date', adminPreview: 'Committee admin preview',
  deleteData: 'Request data deletion', logOut: 'Log out', personal: 'Personal details',
  deleteSent: 'Deletion request sent to the Data Protection officer.',
  // donate / events / docs
  donateSub: 'Paid through Juice, receipted separately from subscriptions.', fund: 'Fund',
  donateNow: 'Donate with Juice', going: 'Going', rsvp: 'RSVP', membersOnly: 'Members only',
  loginToView: 'Log in to open member documents.', docPreview: 'Opens the PDF in the live app.',
  // centenary
  centenarySub: 'A century of community, 1927–2027', programme: 'Centenary programme', sample: 'Sample content · CHI to supply',
  // admin
  adminSub: 'Web admin panel · mobile preview', activeMembers: 'Active members', collected: 'Collected this month',
  pendingRequests: 'Pending requests', accessRequests: 'Access requests', recentPayments: 'Recent payments',
  matched: 'Matched', noMatch: 'No match found', reject: 'Reject', approved: 'Approved', rejected: 'Rejected',
  rejectReason: 'Not found in the society register', nothingPending: 'No requests waiting.',
  // misc
  markAllRead: 'Mark all read', back: 'Back', close: 'Close',
};

export type StringKey = keyof typeof en;

const fr: Record<StringKey, string> = {
  tabHome: 'Accueil', tabCommittee: 'Comité', tabFaq: 'FAQ', tabContacts: 'Contacts', tabMember: 'Membre',
  assalamu: 'Assalamu alaykum', nextPrayer: 'Prochaine prière', inTime: 'dans', allTimes: 'Toutes les heures de prière',
  explore: 'Explorer', latestNews: 'Actualités', seeAll: 'Tout voir', urgent: 'Avis',
  prayerTimes: 'Heures de prière', ramadan: 'Ramadan', qibla: 'Qibla', events: 'Événements', donate: 'Faire un don',
  documents: 'Documents', centenary: 'Centenaire', duas: 'Douas', notifications: 'Notifications',
  fajr: 'Fajr', sunrise: 'Lever du soleil', dhuhr: 'Dhuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha',
  adhanAlert: 'Alerte adhan', prayerMethod: 'Ligue islamique mondiale · Asr hanafite · Port-Louis',
  ramadanBegins: 'Le Ramadan commence dans', days: 'jours', dayOf: 'Jour', suhoor: 'Fin du suhoor', iftar: 'Iftar',
  sightingNote: 'Dates calculées, confirmées par l’observation de la lune.', timetable: 'Calendrier',
  qiblaHint: 'Tenez le téléphone à plat et tournez jusqu’à ce que la flèche pointe vers le haut.', qiblaAligned: 'Face à la Qibla',
  qiblaBearing: 'Direction depuis Port-Louis', qiblaNoSensor: 'Boussole indisponible sur cet appareil. Utilisez la direction ci-dessous.',
  committeeSub: 'Comité de direction 2025–2027', faqSub: 'Réponses aux questions fréquentes',
  searchQuestions: 'Rechercher', noResults: 'Aucune question trouvée.', all: 'Tout',
  contactsSub: 'Venez nous voir, appelez ou écrivez-nous', directions: 'Itinéraire', call: 'Appeler', email: 'E-mail',
  whatsapp: 'WhatsApp', followUs: 'Suivez-nous', officeHours: 'Heures d’ouverture',
  memberLogin: 'Connexion membre', loginSub: 'Accédez à votre cotisation, vos paiements et reçus.',
  emailOrNumber: 'E-mail ou numéro de membre', password: 'Mot de passe', logIn: 'Se connecter',
  forgot: 'Mot de passe oublié ?', requestAccess: 'Demander l’accès', notMember: 'Nouveau sur l’application ?',
  accessNote: 'L’accès est accordé après approbation de votre demande par le comité.',
  unlockBio: 'Déverrouiller par biométrie', welcomeBack: 'Bon retour', bioFailed: 'Vérification biométrique annulée.',
  requestSub: 'Nous comparons vos informations au registre de la société.', fullName: 'Nom complet',
  nic: 'Numéro NIC', mobile: 'Numéro de portable', memberNo: 'Numéro de membre (si connu)',
  consent: 'J’accepte que la CHI traite mes données selon le Data Protection Act 2017.',
  submit: 'Envoyer la demande', requestSent: 'Demande reçue',
  requestSentBody: 'Le secrétaire l’examinera sous peu. Vous serez averti par SMS et e-mail.',
  errName: 'Saisissez votre nom complet', errNic: 'NIC : 1 lettre + 13 caractères', errMobile: 'Portable mauricien : 8 chiffres commençant par 5',
  errEmail: 'Saisissez un e-mail valide', errConsent: 'Le consentement est requis', done: 'Terminé',
  myAccount: 'Mon compte', paidUpTo: 'Payé jusqu’à', nextDue: 'Prochaine échéance', active: 'Actif',
  overdue: 'En retard', due: 'À payer', paid: 'Payé', upcoming: 'À venir', subscription: 'Cotisation',
  payMonths: 'Payer les mois à venir', history: 'Historique et reçus', profile: 'Profil et réglages',
  arrears: 'Arriérés', category: 'Catégorie', memberSince: 'Membre depuis', youOwe: 'Montant dû',
  allClear: 'À jour', bioPrompt: 'Utiliser la biométrie la prochaine fois', enable: 'Activer',
  paySub: 'Les arriérés sont inclus automatiquement.', selectMonths: 'Choisir les mois', total: 'Total',
  monthsSelected: 'mois sélectionnés', payWithJuice: 'Payer avec Juice', redirectNote: 'Vous confirmerez le paiement dans Juice by MCB.',
  checkout: 'Paiement Juice', merchant: 'Marchand', amount: 'Montant', reference: 'Référence',
  sandbox: 'Bac à sable · simulé', outcome: 'Résultat simulé', approve: 'Accepter', decline: 'Refuser',
  stepAuth: 'Autoriser dans Juice', stepServer: 'Confirmation serveur avec la MCB', stepReceipt: 'Reçu émis',
  confirmPay: 'Confirmer le paiement', declined: 'Paiement refusé', declinedBody: 'Aucun montant débité. Vous pouvez réessayer.',
  tryAgain: 'Réessayer', cancel: 'Annuler',
  paymentSuccessful: 'Paiement réussi', donationReceived: 'Don reçu', receiptNo: 'Reçu n°',
  months: 'Mois', date: 'Date', method: 'Moyen', downloadReceipt: 'Télécharger le reçu (PDF)',
  backToAccount: 'Retour à mon compte', emailCopy: 'Une copie a été envoyée à', manual: 'Manuel',
  language: 'Langue', biometrics: 'Déverrouillage biométrique', reminders: 'Rappels de paiement',
  remindersSub: '3 jours avant et après chaque échéance', adminPreview: 'Aperçu admin du comité',
  deleteData: 'Demander la suppression des données', logOut: 'Se déconnecter', personal: 'Informations personnelles',
  deleteSent: 'Demande de suppression envoyée au responsable de la protection des données.',
  donateSub: 'Payé via Juice, reçu séparé des cotisations.', fund: 'Fonds',
  donateNow: 'Donner avec Juice', going: 'Inscrit', rsvp: 'Participer', membersOnly: 'Réservé aux membres',
  loginToView: 'Connectez-vous pour ouvrir les documents des membres.', docPreview: 'Ouvre le PDF dans l’application finale.',
  centenarySub: 'Un siècle de communauté, 1927–2027', programme: 'Programme du centenaire', sample: 'Contenu d’exemple · fourni par la CHI',
  adminSub: 'Panneau d’administration web · aperçu mobile', activeMembers: 'Membres actifs', collected: 'Encaissé ce mois',
  pendingRequests: 'Demandes en attente', accessRequests: 'Demandes d’accès', recentPayments: 'Paiements récents',
  matched: 'Trouvé', noMatch: 'Introuvable', reject: 'Refuser', approved: 'Approuvée', rejected: 'Refusée',
  rejectReason: 'Absent du registre de la société', nothingPending: 'Aucune demande en attente.',
  markAllRead: 'Tout marquer lu', back: 'Retour', close: 'Fermer',
};

export const strings: Record<Lang, Record<StringKey, string>> = { en, fr };

const MONTHS: Record<Lang, string[]> = {
  en: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  fr: ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
};

const HIJRI_MONTHS = [
  'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani',
  'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah',
];

const WEEKDAYS: Record<Lang, string[]> = {
  en: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  fr: ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'],
};

export const monthName = (lang: Lang, m: number, short = false): string => {
  const name = MONTHS[lang][m - 1];
  return short ? name.slice(0, 3) : name;
};

export const hijriMonthName = (m: number): string => HIJRI_MONTHS[m - 1];

export const weekday = (lang: Lang, y: number, m: number, d: number): string =>
  WEEKDAYS[lang][new Date(Date.UTC(y, m - 1, d)).getUTCDay()];

/** "9 November 2026" / "9 novembre 2026" */
export const longDate = (lang: Lang, y: number, m: number, d: number): string => `${d} ${monthName(lang, m)} ${y}`;

/** "MUR 1,350" with Mauritian grouping. */
export const mur = (amount: number): string => `MUR ${amount.toLocaleString('en-US')}`;
