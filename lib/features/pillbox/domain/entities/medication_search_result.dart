class MedicationSearchResult {
  final String externalId;
  final String? cis;
  final String? cip;
  final String name;
  final String? shortLabel;
  final String? form;
  final String? route;
  final String? status;
  final String? marketingStatus;
  final String? reimbursementRate;
  final double? price;
  final String? laboratory;
  final List<String> activeSubstances;
  final String? normalizedForm;
  final String? iconKey;
  final String? source;

  MedicationSearchResult({
    required this.externalId,
    required this.name,
    this.cis,
    this.cip,
    this.shortLabel,
    this.form,
    this.route,
    this.status,
    this.marketingStatus,
    this.reimbursementRate,
    this.price,
    this.laboratory,
    this.activeSubstances = const [],
    this.normalizedForm,
    this.iconKey,
    this.source,
  });

  factory MedicationSearchResult.fromJson(Map<String, dynamic> json) {
    final rawSubstances = (json['activeSubstances'] as List?) ?? const [];
    return MedicationSearchResult(
      externalId: (json['externalId'] ?? '').toString(),
      cis: json['cis'] as String?,
      cip: json['cip'] as String?,
      name: (json['name'] ?? '').toString(),
      shortLabel: json['shortLabel'] as String?,
      form: json['form'] as String?,
      route: json['route'] as String?,
      status: json['status'] as String?,
      marketingStatus: json['marketingStatus'] as String?,
      reimbursementRate: json['reimbursementRate'] as String?,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? ''),
      laboratory: json['laboratory'] as String?,
      activeSubstances: rawSubstances.map((item) => item.toString()).toList(),
      normalizedForm: json['normalizedForm'] as String?,
      iconKey: json['iconKey'] as String?,
      source: json['source'] as String?,
    );
  }
}
