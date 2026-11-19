/// Sample public content. In production all of this comes from the CMS in the admin
/// panel (FR-008); names, numbers and history are placeholders for CHI to replace.
library;

import '../core/utils/time.dart';
import 'models.dart';
import 'photos.dart';

const member = Member(
  name: 'Yusuf Rahim Bhugeloo',
  number: 'CHI-01427',
  email: 'yusuf.bhugeloo@example.mu',
  phone: '+230 5712 4480',
  category: L('Ordinary member', 'Membre ordinaire'),
  since: 2011,
  rate: 150,
);

const societyName = 'Cockney Hudayetool Islam Society';

enum NewsKind { news, janaza, notice }

class NewsItem {
  const NewsItem({
    required this.id,
    required this.kind,
    required this.daysAgo,
    required this.title,
    required this.summary,
    required this.body,
    required this.photo,
  });
  final String id;
  final NewsKind kind;
  final int daysAgo;
  final L title;
  final L summary;
  final L body;
  final Photos photo;
}

const news = <NewsItem>[
  NewsItem(
    id: 'agm-2026',
    photo: Photos.jummahHall,
    kind: NewsKind.notice,
    daysAgo: 1,
    title: L(
      'Annual General Meeting, {agm}',
      'Assemblée générale annuelle, {agm}',
    ),
    summary: L(
      'Agenda, venue and proxy forms now available.',
      'Ordre du jour, lieu et procurations disponibles.',
    ),
    body: L(
      'The AGM will be held after Asr on {agmDay} in the main hall. The agenda covers the treasurer’s report, the centenary programme and the election of two committee members. Proxy forms are in the Documents section of the app.',
      'L’AGA se tiendra après Asr le {agmDay} dans la grande salle. À l’ordre du jour : rapport du trésorier, programme du centenaire et élection de deux membres du comité. Les procurations sont dans la rubrique Documents.',
    ),
  ),
  NewsItem(
    id: 'janaza-1',
    photo: Photos.crescent,
    kind: NewsKind.janaza,
    daysAgo: 2,
    title: L(
      'Janaza: the late Brother Abdool Karim',
      'Janaza : feu notre frère Abdool Karim',
    ),
    summary: L(
      'Inna lillahi wa inna ilayhi raji‘un.',
      'Inna lillahi wa inna ilayhi raji‘un.',
    ),
    body: L(
      'Inna lillahi wa inna ilayhi raji‘un. The janaza salah will be performed after Dhuhr at the society mosque, followed by burial. May Allah grant him Jannat al-Firdaws and give his family patience.',
      'Inna lillahi wa inna ilayhi raji‘un. La salat al-janaza sera accomplie après Dhuhr à la mosquée de la société, suivie de l’inhumation. Qu’Allah lui accorde le Firdaws et donne la patience à sa famille.',
    ),
  ),
  NewsItem(
    id: 'centenary-update',
    photo: Photos.jummah1970s,
    kind: NewsKind.news,
    daysAgo: 6,
    title: L(
      'Centenary 2027: programme taking shape',
      'Centenaire 2027 : le programme se précise',
    ),
    summary: L(
      'Exhibition, lecture series and community iftar confirmed.',
      'Exposition, conférences et iftar communautaire confirmés.',
    ),
    body: L(
      'The centenary committee has confirmed a heritage exhibition, a lecture series on the history of the community and a society-wide iftar during Ramadan 1448. Families holding photographs from the early decades are invited to share them with the secretary.',
      'Le comité du centenaire a confirmé une exposition patrimoniale, un cycle de conférences sur l’histoire de la communauté et un iftar ouvert à tous pendant le Ramadan 1448. Les familles possédant des photos des premières décennies sont invitées à les partager avec le secrétaire.',
    ),
  ),
  NewsItem(
    id: 'madrassah',
    photo: Photos.doorway,
    kind: NewsKind.news,
    daysAgo: 11,
    title: L(
      'Madrassah enrolment open for 2027',
      'Inscriptions à la madrassah 2027',
    ),
    summary: L(
      'Weekend classes for ages 5 to 14.',
      'Cours du week-end pour les 5 à 14 ans.',
    ),
    body: L(
      'Enrolment for weekend madrassah classes is open until 15 December. Places are limited; priority goes to children of members.',
      'Les inscriptions aux cours de madrassah du week-end sont ouvertes jusqu’au 15 décembre. Places limitées, priorité aux enfants des membres.',
    ),
  ),
];

class CommitteeMember {
  const CommitteeMember(this.name, this.role, {this.phone, this.email});
  final String name;
  final L role;
  final String? phone;
  final String? email;
}

const committee = <CommitteeMember>[
  CommitteeMember(
    'Haji Rashid Goolamally',
    L('President', 'Président'),
    phone: '+2302123456',
    email: 'president@chi.mu',
  ),
  CommitteeMember('Nazir Peerbaccus', L('Vice-President', 'Vice-président')),
  CommitteeMember(
    'Fazila Hossenbux',
    L('Secretary', 'Secrétaire'),
    email: 'secretary@chi.mu',
  ),
  CommitteeMember(
    'Imran Joomun',
    L('Treasurer', 'Trésorier'),
    email: 'treasurer@chi.mu',
  ),
  CommitteeMember(
    'Shabnam Ramjan',
    L('Assistant Secretary', 'Secrétaire adjointe'),
  ),
  CommitteeMember(
    'Yacoob Dilmohamed',
    L('Committee member', 'Membre du comité'),
  ),
  CommitteeMember('Anwar Soobratty', L('Committee member', 'Membre du comité')),
];

enum FaqCategory {
  membership(L('Membership', 'Adhésion')),
  payments(L('Payments', 'Paiements')),
  app(L('Using the app', 'L’application'));

  const FaqCategory(this.label);
  final L label;
}

class Faq {
  const Faq(this.category, this.q, this.a);
  final FaqCategory category;
  final L q;
  final L a;
}

const faqs = <Faq>[
  Faq(
    FaqCategory.membership,
    L('How do I become a member?', 'Comment devenir membre ?'),
    L(
      'Collect a form from the secretary’s office after any Jumu‘ah, or download it from Documents. Existing members can request app access from the Member tab.',
      'Retirez un formulaire au secrétariat après la Jumu‘ah, ou téléchargez-le dans Documents. Les membres existants demandent l’accès depuis l’onglet Membre.',
    ),
  ),
  Faq(
    FaqCategory.membership,
    L('Can I add my family?', 'Puis-je ajouter ma famille ?'),
    L(
      'Yes. Household members are linked by the secretary, and the head of household can pay for everyone in one payment.',
      'Oui. Le secrétaire relie les membres du foyer, et le chef de famille peut tout payer en une fois.',
    ),
  ),
  Faq(
    FaqCategory.payments,
    L('How are subscriptions paid?', 'Comment payer la cotisation ?'),
    L(
      'In the app through Juice by MCB, for one or several months at once. Cash and bank transfers are still accepted at the office and recorded by the treasurer.',
      'Dans l’application via Juice by MCB, pour un ou plusieurs mois. Les espèces et virements restent acceptés au bureau et enregistrés par le trésorier.',
    ),
  ),
  Faq(
    FaqCategory.payments,
    L('Can I get a receipt?', 'Puis-je obtenir un reçu ?'),
    L(
      'Every payment produces a PDF receipt that is emailed to you and kept under Payment history.',
      'Chaque paiement génère un reçu PDF envoyé par e-mail et conservé dans l’historique.',
    ),
  ),
  Faq(
    FaqCategory.payments,
    L('What if I am behind on payments?', 'Et si j’ai des arriérés ?'),
    L(
      'Arrears are added to your next payment automatically. If you are facing hardship, speak to the treasurer in confidence.',
      'Les arriérés s’ajoutent automatiquement au prochain paiement. En cas de difficulté, parlez-en au trésorier en toute confidentialité.',
    ),
  ),
  Faq(
    FaqCategory.app,
    L(
      'How are prayer times calculated?',
      'Comment les heures de prière sont-elles calculées ?',
    ),
    L(
      'For Port Louis using the method agreed with the committee. They work offline and update daily.',
      'Pour Port-Louis selon la méthode validée par le comité. Elles fonctionnent hors ligne.',
    ),
  ),
  Faq(
    FaqCategory.app,
    L('Is my data safe?', 'Mes données sont-elles protégées ?'),
    L(
      'Data is encrypted in transit and at rest, card details never touch our servers, and you can request deletion at any time.',
      'Les données sont chiffrées, les données de carte ne passent jamais par nos serveurs, et vous pouvez demander leur suppression.',
    ),
  ),
];

abstract final class Contacts {
  static const address = 'Society Mosque, Port Louis, Mauritius';
  static const lat = -20.1619;
  static const lng = 57.4989;
  static const phone = '+230 212 3456';
  static const whatsapp = '23052123456';
  static const email = 'info@chi.mu';
  static const hours = L(
    'Mon–Fri 9:00–16:00 · after Jumu‘ah',
    'Lun–ven 9h00–16h00 · après la Jumu‘ah',
  );
  static const social = <(String, String)>[
    ('Facebook', 'https://facebook.com'),
    ('Instagram', 'https://instagram.com'),
    ('YouTube', 'https://youtube.com'),
  ];
}

class EventItem {
  const EventItem({
    required this.id,
    required this.inDays,
    required this.time,
    required this.title,
    required this.place,
    required this.photo,
    this.membersOnly = false,
    this.onSunday = false,
  });
  final String id;

  /// Days from today. With [onSunday], the event falls on the first Sunday on or after that.
  final int inDays;
  final bool onSunday;
  final String time;
  final L title;
  final String place;
  final bool membersOnly;
  final Photos photo;

  /// The event's date, always in the future relative to [today] so the demo never goes stale.
  Ymd dayFrom(Ymd today) {
    final day = addDays(today, inDays);
    return onSunday ? addDays(day, (7 - weekdayIndex(day)) % 7) : day;
  }
}

/// Events sorted soonest first.
List<EventItem> upcomingEvents(Ymd today) => [...events]
  ..sort((a, b) => _ord(a.dayFrom(today)).compareTo(_ord(b.dayFrom(today))));

int _ord(Ymd d) => d.y * 10000 + d.m * 100 + d.d;

const events = <EventItem>[
  EventItem(
    id: 'agm',
    photo: Photos.jummahHall,
    inDays: 10,
    onSunday: true, // the AGM is held on a Sunday after Asr
    time: '16:45',
    title: L('Annual General Meeting', 'Assemblée générale annuelle'),
    place: 'Main hall',
    membersOnly: true,
  ),
  EventItem(
    id: 'lecture',
    photo: Photos.doorway,
    inDays: 6,
    time: '19:45',
    title: L('Seerah lecture series', 'Cycle de conférences sur la Sîra'),
    place: 'Society mosque',
  ),
  EventItem(
    id: 'cleanup',
    photo: Photos.jummahCourtyard,
    inDays: 13,
    time: '08:00',
    title: L('Community clean-up day', 'Journée de nettoyage'),
    place: 'Mosque grounds',
  ),
  EventItem(
    id: 'iftar',
    photo: Photos.crescent,
    inDays: 92,
    time: '18:30',
    title: L('Centenary community iftar', 'Iftar communautaire du centenaire'),
    place: 'Main hall',
  ),
];

class Fund {
  const Fund(this.id, this.label);
  final String id;
  final L label;
}

const funds = <Fund>[
  Fund('zakat', L('Zakat', 'Zakat')),
  Fund('sadaqah', L('Sadaqah', 'Sadaqa')),
  Fund('mosque', L('Mosque upkeep', 'Entretien de la mosquée')),
  Fund('centenary', L('Centenary fund', 'Fonds du centenaire')),
];

Fund? fundById(String? id) => funds.where((f) => f.id == id).firstOrNull;

class Doc {
  const Doc(this.id, this.title, this.meta, {this.membersOnly = false});
  final String id;
  final L title;
  final String meta;
  final bool membersOnly;
}

const documents = <Doc>[
  Doc(
    'constitution',
    L('Society constitution', 'Statuts de la société'),
    'PDF · 412 KB',
  ),
  Doc(
    'membership-form',
    L('Membership form', 'Formulaire d’adhésion'),
    'PDF · 96 KB',
  ),
  Doc(
    'agm-2025',
    L('AGM minutes 2025', 'Procès-verbal AGA 2025'),
    'PDF · 238 KB',
    membersOnly: true,
  ),
  Doc(
    'accounts-2025',
    L('Audited accounts 2025', 'Comptes audités 2025'),
    'PDF · 1.2 MB',
    membersOnly: true,
  ),
  Doc(
    'proxy',
    L('AGM proxy form', 'Procuration AGA'),
    'PDF · 64 KB',
    membersOnly: true,
  ),
];

const timeline = <(String, L)>[
  (
    '1927',
    L(
      'The society is founded by a small group of families in Port Louis.',
      'La société est fondée par quelques familles à Port-Louis.',
    ),
  ),
  (
    '1950s',
    L(
      'The first madrassah opens alongside the mosque.',
      'La première madrassah ouvre à côté de la mosquée.',
    ),
  ),
  (
    '1980s',
    L(
      'The main hall is built through community donations.',
      'La grande salle est construite grâce aux dons.',
    ),
  ),
  (
    '2000s',
    L(
      'Welfare fund established for families in need.',
      'Création d’un fonds social pour les familles.',
    ),
  ),
  (
    '2027',
    L(
      'One hundred years of service to the community.',
      'Cent ans au service de la communauté.',
    ),
  ),
];

class Dua {
  const Dua({
    required this.title,
    required this.arabic,
    required this.translit,
    required this.meaning,
    required this.source,
  });
  final L title;
  final String arabic;
  final String translit;
  final L meaning;
  final String source;
}

const duas = <Dua>[
  Dua(
    title: L('On breaking the fast', 'À la rupture du jeûne'),
    arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
    translit: 'Dhahaba al-zama’u wabtallati al-‘uruqu wa thabata al-ajru in sha’ Allah',
    meaning: L(
      'Thirst has gone, the veins are moistened, and the reward is assured, if Allah wills.',
      'La soif est partie, les veines sont humectées et la récompense est acquise, si Allah le veut.',
    ),
    source: 'Abu Dawud',
  ),
  Dua(
    title: L('Entering the mosque', 'En entrant à la mosquée'),
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    translit: 'Allahumma iftah li abwaba rahmatik',
    meaning: L(
      'O Allah, open for me the doors of Your mercy.',
      'Ô Allah, ouvre-moi les portes de Ta miséricorde.',
    ),
    source: 'Muslim',
  ),
  Dua(
    title: L('For good in both worlds', 'Pour le bien dans les deux mondes'),
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    translit: 'Rabbana atina fi al-dunya hasanatan wa fi al-akhirati hasanatan wa qina ‘adhab al-nar',
    meaning: L(
      'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      'Seigneur, accorde-nous une belle part ici-bas et une belle part dans l’au-delà, et protège-nous du châtiment du Feu.',
    ),
    source: 'Qur’an 2:201',
  ),
  Dua(
    title: L('On hearing of a death', 'À l’annonce d’un décès'),
    arabic: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    translit: 'Inna lillahi wa inna ilayhi raji‘un',
    meaning: L(
      'Indeed we belong to Allah, and indeed to Him we will return.',
      'Nous appartenons à Allah et c’est à Lui que nous retournerons.',
    ),
    source: 'Qur’an 2:156',
  ),
];

class InboxItem {
  const InboxItem(this.kind, this.daysAgo, this.title, this.body, this.route);
  final String kind; // subscription | notice | janaza | event
  final int daysAgo;
  final L title;
  final L body;
  final String route;
}

const inbox = <InboxItem>[
  InboxItem(
    'subscription',
    0,
    L('Subscription due', 'Cotisation à payer'),
    L(
      'Your subscription for this month is due. You also have one overdue month.',
      'Votre cotisation du mois est due. Un mois est également en retard.',
    ),
    '/member',
  ),
  InboxItem(
    'notice',
    1,
    L('AGM on {agm}', 'AGA le {agm}'),
    L(
      'Agenda and proxy forms are now available.',
      'Ordre du jour et procurations disponibles.',
    ),
    '/news/agm-2026',
  ),
  InboxItem(
    'janaza',
    2,
    L('Janaza announcement', 'Annonce de janaza'),
    L(
      'Janaza salah after Dhuhr at the society mosque.',
      'Salat al-janaza après Dhuhr à la mosquée.',
    ),
    '/news/janaza-1',
  ),
  InboxItem(
    'event',
    4,
    L('Seerah lecture this week', 'Conférence sur la Sîra cette semaine'),
    L(
      'After Isha in the society mosque. RSVP in the app.',
      'Après Isha à la mosquée. Inscription dans l’application.',
    ),
    '/events',
  ),
];
