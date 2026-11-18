/// Access-request validation (FR-011, US-02). Input is accepted liberally (spaces, dashes,
/// lower case, with or without +230) and normalised before checking.
library;

String normaliseNic(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

String normaliseMobile(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length == 11 && digits.startsWith('230')
      ? digits.substring(3)
      : digits;
}

// Mauritian NIC: surname initial + 12 digits + check character. Mobiles: 8 digits starting with 5.
final _nic = RegExp(r'^[A-Z]\d{12}[A-Z0-9]$');
final _mobile = RegExp(r'^5\d{7}$');
final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

enum FieldError { name, nic, mobile, email, consent }

Set<FieldError> validateRequest({
  required String name,
  required String nic,
  required String mobile,
  required String email,
  required bool consent,
}) => {
  if (name.trim().split(RegExp(r'\s+')).length < 2) FieldError.name,
  if (!_nic.hasMatch(normaliseNic(nic))) FieldError.nic,
  if (!_mobile.hasMatch(normaliseMobile(mobile))) FieldError.mobile,
  if (!_email.hasMatch(email.trim())) FieldError.email,
  if (!consent) FieldError.consent,
};
