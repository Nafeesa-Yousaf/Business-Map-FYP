class PriceConverter {
  static String format(dynamic price) {
    if (price == null) return "0";
    String value = price.toString();
    List<String> parts = value.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return formattedInteger + decimalPart;
  }
}
