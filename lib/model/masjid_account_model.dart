class MasjidAccount {
  final String masjidName;
  final String accNum;
  final String bankName;

  MasjidAccount({
    required this.masjidName,
    required this.accNum,
    required this.bankName,
  });

  factory MasjidAccount.fromJson(Map<String, dynamic> json) {
    return MasjidAccount(
      masjidName: json['masjidName'],
      accNum: json['accNum'],
      bankName: json['bankName'],
    );
  }
}
