class RentalItemModel {
  Map<String, dynamic> attribute;
  int? selectedAttributeId;
  int quantity;

  RentalItemModel({
    required this.attribute,
    this.selectedAttributeId,
    this.quantity = 1,
  });

  int get id => int.tryParse(attribute['id']?.toString() ?? '0') ?? 0;
  String get name => attribute['name']?.toString() ?? '-';
  int get price => int.tryParse(attribute['price_hour']?.toString() ?? '0') ?? 0;
  int get stock => int.tryParse(attribute['stock']?.toString() ?? '0') ?? 0;
  int get fieldId => int.tryParse(attribute['fk_field_id']?.toString() ?? '0') ?? 0;
}