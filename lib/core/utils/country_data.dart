class Country {
  final String name;
  final String flag;
  final String code;
  final String dialCode;

  const Country({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });
}

// Daftar negara yang diperluas menggunakan emoji bendera
final List<Country> availableCountries = [
  // Asia Tenggara & Asia
  const Country(name: "Indonesia", flag: "🇮🇩", code: "ID", dialCode: "+62"),
  const Country(name: "Malaysia", flag: "🇲🇾", code: "MY", dialCode: "+60"),
  const Country(name: "Singapore", flag: "🇸🇬", code: "SG", dialCode: "+65"),
  const Country(name: "Philippines", flag: "🇵🇭", code: "PH", dialCode: "+63"),
  const Country(name: "Thailand", flag: "🇹🇭", code: "TH", dialCode: "+66"),
  const Country(name: "Vietnam", flag: "🇻🇳", code: "VN", dialCode: "+84"),
  const Country(name: "Japan", flag: "🇯🇵", code: "JP", dialCode: "+81"),
  const Country(name: "South Korea", flag: "🇰🇷", code: "KR", dialCode: "+82"),
  const Country(name: "China", flag: "🇨🇳", code: "CN", dialCode: "+86"),
  const Country(name: "India", flag: "🇮🇳", code: "IN", dialCode: "+91"),

  // Amerika
  const Country(name: "United States", flag: "🇺🇸", code: "US", dialCode: "+1"),
  const Country(name: "Canada", flag: "🇨🇦", code: "CA", dialCode: "+1"),
  const Country(name: "Brazil", flag: "🇧🇷", code: "BR", dialCode: "+55"),
  const Country(name: "Mexico", flag: "🇲🇽", code: "MX", dialCode: "+52"),

  // Eropa
  const Country(name: "Germany", flag: "🇩🇪", code: "DE", dialCode: "+49"),
  const Country(name: "France", flag: "🇫🇷", code: "FR", dialCode: "+33"),
  const Country(name: "United Kingdom", flag: "🇬🇧", code: "GB", dialCode: "+44"),
  const Country(name: "Italy", flag: "🇮🇹", code: "IT", dialCode: "+39"),

  // Oceania & Afrika
  const Country(name: "Australia", flag: "🇦🇺", code: "AU", dialCode: "+61"),
  const Country(name: "New Zealand", flag: "🇳🇿", code: "NZ", dialCode: "+64"),
  const Country(name: "South Africa", flag: "🇿🇦", code: "ZA", dialCode: "+27"),
];