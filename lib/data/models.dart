/// Domain types (mirror the data model in section 9 of the requirements).
library;

enum Lang { en, fr }

/// A string supplied in every app language (content from the CMS, FR-008).
class L {
  const L(this.en, this.fr);
  final String en;
  final String fr;
  String of(Lang lang) => lang == Lang.fr ? fr : en;
}

enum MonthStatus { paid, overdue, due, upcoming }

enum PayMethod { juice, cash, bank }

enum PaymentKind { subscription, donation }

enum RequestStatus { pending, approved, rejected }

/// FR-018: only Active members can pay; Inactive see their balance; Deceased have no access.
enum MemberStatus { active, inactive, deceased }

class Month {
  const Month({
    required this.y,
    required this.m,
    required this.amount,
    this.paymentId,
  });
  final int y;
  final int m;
  final int amount; // MUR, whole rupees
  final String? paymentId;

  String get key => monthKey(y, m);
  bool get isPaid => paymentId != null;

  Month paidBy(String id) => Month(y: y, m: m, amount: amount, paymentId: id);
}

String monthKey(int y, int m) => '$y-${m.toString().padLeft(2, '0')}';

class Payment {
  const Payment({
    required this.id,
    required this.receiptNo,
    required this.ref,
    required this.kind,
    required this.method,
    required this.amount,
    required this.monthKeys,
    required this.date,
    this.fund,
    this.anonymous = false,
  });

  final String id;
  final String receiptNo;
  final String ref; // Juice transaction reference, or manual reference
  final PaymentKind kind;
  final PayMethod method;
  final int amount;
  final List<String> monthKeys;
  final String? fund;
  final DateTime date;

  /// A donation made by a visitor who is not logged in: not tied to any member account,
  /// so it carries no member number and stays out of the member's history.
  final bool anonymous;

  Payment withMonths(List<String> keys) => Payment(
    id: id,
    receiptNo: receiptNo,
    ref: ref,
    kind: kind,
    method: method,
    amount: amount,
    monthKeys: keys,
    date: date,
    fund: fund,
    anonymous: anonymous,
  );
}

class AccessRequest {
  const AccessRequest({
    required this.id,
    required this.name,
    required this.nic,
    required this.mobile,
    required this.email,
    required this.matched,
    required this.submitted,
    this.status = RequestStatus.pending,
    this.reason,
  });

  final String id;
  final String name;
  final String nic;
  final String mobile;
  final String email;
  final bool matched;
  final RequestStatus status;
  final DateTime submitted;

  /// Why the request was rejected (FR-013); null for pending or approved requests.
  final String? reason;

  AccessRequest withStatus(RequestStatus s, {String? reason}) => AccessRequest(
    id: id,
    name: name,
    nic: nic,
    mobile: mobile,
    email: email,
    matched: matched,
    submitted: submitted,
    status: s,
    reason: reason,
  );
}

class Member {
  const Member({
    required this.name,
    required this.number,
    required this.email,
    required this.phone,
    required this.category,
    required this.since,
    required this.rate,
    this.status = MemberStatus.active,
  });

  final String name;
  final String number;
  final String email;
  final String phone;
  final L category;
  final int since;
  final int rate; // monthly, MUR
  final MemberStatus status;
}
