class AddressSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  AddressSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat'] ?? '0.0') ?? 0.0,
      lon: double.tryParse(json['lon'] ?? '0.0') ?? 0.0,
    );
  }
}