class CompanyProfile {
  const CompanyProfile({
    required this.name,
    required this.tagline,
    required this.address,
    required this.gstinUin,
    required this.stateName,
    required this.stateCode,
    required this.emailId,
    this.logoPath,
  });

  final String name;
  final String tagline;
  final String address;
  final String gstinUin;
  final String stateName;
  final String stateCode;
  final String emailId;
  final String? logoPath;

  CompanyProfile copyWith({
    String? name,
    String? tagline,
    String? address,
    String? gstinUin,
    String? stateName,
    String? stateCode,
    String? emailId,
    String? logoPath,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      gstinUin: gstinUin ?? this.gstinUin,
      stateName: stateName ?? this.stateName,
      stateCode: stateCode ?? this.stateCode,
      emailId: emailId ?? this.emailId,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
