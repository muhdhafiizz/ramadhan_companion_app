class Sadaqah {
  final String organization;
  final String bankName;
  final String accountNumber;
  final String reference;
  final String url;

  Sadaqah({
    required this.organization,
    required this.bankName,
    required this.accountNumber,
    required this.reference,
    required this.url,
  });

  factory Sadaqah.fromJson(Map<String, dynamic> json) {
    return Sadaqah(
      organization: json['organization'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      reference: json['reference'] ?? "",
      url: json['url'],
    );
  }
}
