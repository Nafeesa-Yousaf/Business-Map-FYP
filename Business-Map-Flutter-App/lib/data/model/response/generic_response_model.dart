class GenericResponseModel<T> {
  final bool success;
  final String message;
  final T? data;

  GenericResponseModel({
    required this.success,
    required this.message,
    this.data,
  });
}
