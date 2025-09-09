class Sadaqah {
  final String id;
  final String organization;
  final String bankName;
  final String accountNumber;
  final String reference;
  final String url;
  final String submittedBy;
  final String status;
  final String category;

  Sadaqah({
    required this.id,
    required this.organization,
    required this.bankName,
    required this.accountNumber,
    required this.reference,
    required this.url,
    required this.submittedBy,
    required this.status,
    required this.category
  });

  factory Sadaqah.fromJson(Map<String, dynamic> json, String id) {
    return Sadaqah(
      id: id,
      organization: json['organization'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      reference: json['reference'] ?? '',
      url: json['url'] ?? '',
      submittedBy: json['submittedBy'] ?? '',
      status: json['status'] ?? 'pending',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'reference': reference,
      'url': url,
      'submittedBy': submittedBy,
      'status': status,
      'category':category
    };
  }
}
