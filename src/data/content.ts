/**
 * Sample public content. In production all of this comes from the CMS in the
 * admin panel (FR-008); names, numbers and history are placeholders for CHI to replace.
 */
import type { Localized } from '@/lib/i18n';

export type NewsKind = 'news' | 'janaza' | 'notice';
export interface NewsItem {
  id: string;
  kind: NewsKind;
  daysAgo: number;
  title: Localized;
  summary: Localized;
  body: Localized;
}

export const news: NewsItem[] = [
  {
    id: 'agm-2026',
    kind: 'notice',
    daysAgo: 1,
    title: { en: 'Annual General Meeting, 29 November', fr: 'Assemblée générale annuelle, 29 novembre' },
    summary: { en: 'Agenda, venue and proxy forms now available.', fr: 'Ordre du jour, lieu et procurations disponibles.' },
    body: {
      en: 'The AGM will be held after Asr on Sunday 29 November in the main hall. The agenda covers the treasurer’s report, the centenary programme and the election of two committee members. Proxy forms are in the Documents section of the app.',
      fr: 'L’AGA se tiendra après Asr le dimanche 29 novembre dans la grande salle. À l’ordre du jour : rapport du trésorier, programme du centenaire et élection de deux membres du comité. Les procurations sont dans la rubrique Documents.',
    },
  },
  {
    id: 'janaza-1',
    kind: 'janaza',
    daysAgo: 2,
    title: { en: 'Janaza: the late Brother Abdool Karim', fr: 'Janaza : feu notre frère Abdool Karim' },
    summary: { en: 'Inna lillahi wa inna ilayhi raji‘un.', fr: 'Inna lillahi wa inna ilayhi raji‘un.' },
    body: {
      en: 'Inna lillahi wa inna ilayhi raji‘un. The janaza salah will be performed after Dhuhr at the society mosque, followed by burial. May Allah grant him Jannat al-Firdaws and give his family patience.',
      fr: 'Inna lillahi wa inna ilayhi raji‘un. La salat al-janaza sera accomplie après Dhuhr à la mosquée de la société, suivie de l’inhumation. Qu’Allah lui accorde le Firdaws et donne la patience à sa famille.',
    },
  },
  {
    id: 'centenary-update',
    kind: 'news',
    daysAgo: 6,
    title: { en: 'Centenary 2027: programme taking shape', fr: 'Centenaire 2027 : le programme se précise' },
    summary: { en: 'Exhibition, lecture series and community iftar confirmed.', fr: 'Exposition, conférences et iftar communautaire confirmés.' },
    body: {
      en: 'The centenary committee has confirmed a heritage exhibition, a lecture series on the history of the community and a society-wide iftar during Ramadan 1448. Families holding photographs from the early decades are invited to share them with the secretary.',
      fr: 'Le comité du centenaire a confirmé une exposition patrimoniale, un cycle de conférences sur l’histoire de la communauté et un iftar ouvert à tous pendant le Ramadan 1448. Les familles possédant des photos des premières décennies sont invitées à les partager avec le secrétaire.',
    },
  },
  {
    id: 'madrassah',
    kind: 'news',
    daysAgo: 11,
    title: { en: 'Madrassah enrolment open for 2027', fr: 'Inscriptions à la madrassah 2027' },
    summary: { en: 'Weekend classes for ages 5 to 14.', fr: 'Cours du week-end pour les 5 à 14 ans.' },
    body: {
      en: 'Enrolment for weekend madrassah classes is open until 15 December. Places are limited; priority goes to children of members.',
      fr: 'Les inscriptions aux cours de madrassah du week-end sont ouvertes jusqu’au 15 décembre. Places limitées, priorité aux enfants des membres.',
    },
  },
];

export interface CommitteeMember {
  name: string;
  role: Localized;
  phone?: string;
  email?: string;
}

export const committee: CommitteeMember[] = [
  { name: 'Haji Rashid Goolamally', role: { en: 'President', fr: 'Président' }, phone: '+2302123456', email: 'president@chi.mu' },
  { name: 'Nazir Peerbaccus', role: { en: 'Vice-President', fr: 'Vice-président' } },
  { name: 'Fazila Hossenbux', role: { en: 'Secretary', fr: 'Secrétaire' }, email: 'secretary@chi.mu' },
  { name: 'Imran Joomun', role: { en: 'Treasurer', fr: 'Trésorier' }, email: 'treasurer@chi.mu' },
  { name: 'Shabnam Ramjan', role: { en: 'Assistant Secretary', fr: 'Secrétaire adjointe' } },
  { name: 'Yacoob Dilmohamed', role: { en: 'Committee member', fr: 'Membre du comité' } },
  { name: 'Anwar Soobratty', role: { en: 'Committee member', fr: 'Membre du comité' } },
];

export type FaqCategory = 'membership' | 'payments' | 'app';
export const faqCategories: { id: FaqCategory; label: Localized }[] = [
  { id: 'membership', label: { en: 'Membership', fr: 'Adhésion' } },
  { id: 'payments', label: { en: 'Payments', fr: 'Paiements' } },
  { id: 'app', label: { en: 'Using the app', fr: 'L’application' } },
];

export const faqs: { category: FaqCategory; q: Localized; a: Localized }[] = [
  {
    category: 'membership',
    q: { en: 'How do I become a member?', fr: 'Comment devenir membre ?' },
    a: { en: 'Collect a form from the secretary’s office after any Jumu‘ah, or download it from Documents. Existing members can request app access from the Member tab.', fr: 'Retirez un formulaire au secrétariat après la Jumu‘ah, ou téléchargez-le dans Documents. Les membres existants demandent l’accès depuis l’onglet Membre.' },
  },
  {
    category: 'membership',
    q: { en: 'Can I add my family?', fr: 'Puis-je ajouter ma famille ?' },
    a: { en: 'Yes. Household members are linked by the secretary, and the head of household can pay for everyone in one payment.', fr: 'Oui. Le secrétaire relie les membres du foyer, et le chef de famille peut tout payer en une fois.' },
  },
  {
    category: 'payments',
    q: { en: 'How are subscriptions paid?', fr: 'Comment payer la cotisation ?' },
    a: { en: 'In the app through Juice by MCB, for one or several months at once. Cash and bank transfers are still accepted at the office and recorded by the treasurer.', fr: 'Dans l’application via Juice by MCB, pour un ou plusieurs mois. Les espèces et virements restent acceptés au bureau et enregistrés par le trésorier.' },
  },
  {
    category: 'payments',
    q: { en: 'Can I get a receipt?', fr: 'Puis-je obtenir un reçu ?' },
    a: { en: 'Every payment produces a PDF receipt that is emailed to you and kept under Payment history.', fr: 'Chaque paiement génère un reçu PDF envoyé par e-mail et conservé dans l’historique.' },
  },
  {
    category: 'payments',
    q: { en: 'What if I am behind on payments?', fr: 'Et si j’ai des arriérés ?' },
    a: { en: 'Arrears are added to your next payment automatically. If you are facing hardship, speak to the treasurer in confidence.', fr: 'Les arriérés s’ajoutent automatiquement au prochain paiement. En cas de difficulté, parlez-en au trésorier en toute confidentialité.' },
  },
  {
    category: 'app',
    q: { en: 'How are prayer times calculated?', fr: 'Comment les heures de prière sont-elles calculées ?' },
    a: { en: 'For Port Louis using the method agreed with the committee. They work offline and update daily.', fr: 'Pour Port-Louis selon la méthode validée par le comité. Elles fonctionnent hors ligne.' },
  },
  {
    category: 'app',
    q: { en: 'Is my data safe?', fr: 'Mes données sont-elles protégées ?' },
    a: { en: 'Data is encrypted in transit and at rest, card details never touch our servers, and you can request deletion at any time.', fr: 'Les données sont chiffrées, les données de carte ne passent jamais par nos serveurs, et vous pouvez demander leur suppression.' },
  },
];

export const contacts = {
  address: 'Society Mosque, Port Louis, Mauritius',
  coords: { lat: -20.1619, lng: 57.4989 },
  phone: '+230 212 3456',
  whatsapp: '23052123456',
  email: 'info@chi.mu',
  hours: { en: 'Mon–Fri 9:00–16:00 · after Jumu‘ah', fr: 'Lun–ven 9h00–16h00 · après la Jumu‘ah' } as Localized,
  social: [
    { icon: 'facebook', label: 'Facebook', url: 'https://facebook.com' },
    { icon: 'instagram', label: 'Instagram', url: 'https://instagram.com' },
    { icon: 'youtube', label: 'YouTube', url: 'https://youtube.com' },
  ] as const,
};

export interface EventItem {
  id: string;
  inDays: number;
  time: string;
  title: Localized;
  place: string;
  membersOnly?: boolean;
}

export const events: EventItem[] = [
  { id: 'agm', inDays: 20, time: '16:45', title: { en: 'Annual General Meeting', fr: 'Assemblée générale annuelle' }, place: 'Main hall', membersOnly: true },
  { id: 'lecture', inDays: 6, time: '19:45', title: { en: 'Seerah lecture series', fr: 'Cycle de conférences sur la Sîra' }, place: 'Society mosque' },
  { id: 'cleanup', inDays: 13, time: '08:00', title: { en: 'Community clean-up day', fr: 'Journée de nettoyage' }, place: 'Mosque grounds' },
  { id: 'iftar', inDays: 92, time: '18:30', title: { en: 'Centenary community iftar', fr: 'Iftar communautaire du centenaire' }, place: 'Main hall' },
];

export const funds: { id: string; label: Localized }[] = [
  { id: 'zakat', label: { en: 'Zakat', fr: 'Zakat' } },
  { id: 'sadaqah', label: { en: 'Sadaqah', fr: 'Sadaqa' } },
  { id: 'mosque', label: { en: 'Mosque upkeep', fr: 'Entretien de la mosquée' } },
  { id: 'centenary', label: { en: 'Centenary fund', fr: 'Fonds du centenaire' } },
];

export const documents: { id: string; title: Localized; meta: string; membersOnly: boolean }[] = [
  { id: 'constitution', title: { en: 'Society constitution', fr: 'Statuts de la société' }, meta: 'PDF · 412 KB', membersOnly: false },
  { id: 'membership-form', title: { en: 'Membership form', fr: 'Formulaire d’adhésion' }, meta: 'PDF · 96 KB', membersOnly: false },
  { id: 'agm-2025', title: { en: 'AGM minutes 2025', fr: 'Procès-verbal AGA 2025' }, meta: 'PDF · 238 KB', membersOnly: true },
  { id: 'accounts-2025', title: { en: 'Audited accounts 2025', fr: 'Comptes audités 2025' }, meta: 'PDF · 1.2 MB', membersOnly: true },
  { id: 'proxy', title: { en: 'AGM proxy form', fr: 'Procuration AGA' }, meta: 'PDF · 64 KB', membersOnly: true },
];

export const timeline: { year: string; text: Localized }[] = [
  { year: '1927', text: { en: 'The society is founded by a small group of families in Port Louis.', fr: 'La société est fondée par quelques familles à Port-Louis.' } },
  { year: '1950s', text: { en: 'The first madrassah opens alongside the mosque.', fr: 'La première madrassah ouvre à côté de la mosquée.' } },
  { year: '1980s', text: { en: 'The main hall is built through community donations.', fr: 'La grande salle est construite grâce aux dons.' } },
  { year: '2000s', text: { en: 'Welfare fund established for families in need.', fr: 'Création d’un fonds social pour les familles.' } },
  { year: '2027', text: { en: 'One hundred years of service to the community.', fr: 'Cent ans au service de la communauté.' } },
];

export const duas: { id: string; title: Localized; arabic: string; translit: string; meaning: Localized; source: string }[] = [
  {
    id: 'iftar',
    title: { en: 'On breaking the fast', fr: 'À la rupture du jeûne' },
    arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
    translit: 'Dhahaba al-zama’u wabtallati al-‘uruqu wa thabata al-ajru in sha’ Allah',
    meaning: { en: 'Thirst has gone, the veins are moistened, and the reward is assured, if Allah wills.', fr: 'La soif est partie, les veines sont humectées et la récompense est acquise, si Allah le veut.' },
    source: 'Abu Dawud',
  },
  {
    id: 'mosque',
    title: { en: 'Entering the mosque', fr: 'En entrant à la mosquée' },
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    translit: 'Allahumma iftah li abwaba rahmatik',
    meaning: { en: 'O Allah, open for me the doors of Your mercy.', fr: 'Ô Allah, ouvre-moi les portes de Ta miséricorde.' },
    source: 'Muslim',
  },
  {
    id: 'rabbana',
    title: { en: 'For good in both worlds', fr: 'Pour le bien dans les deux mondes' },
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    translit: 'Rabbana atina fi al-dunya hasanatan wa fi al-akhirati hasanatan wa qina ‘adhab al-nar',
    meaning: { en: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.', fr: 'Seigneur, accorde-nous une belle part ici-bas et une belle part dans l’au-delà, et protège-nous du châtiment du Feu.' },
    source: 'Qur’an 2:201',
  },
  {
    id: 'loss',
    title: { en: 'On hearing of a death', fr: 'À l’annonce d’un décès' },
    arabic: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    translit: 'Inna lillahi wa inna ilayhi raji‘un',
    meaning: { en: 'Indeed we belong to Allah, and indeed to Him we will return.', fr: 'Nous appartenons à Allah et c’est à Lui que nous retournerons.' },
    source: 'Qur’an 2:156',
  },
];
