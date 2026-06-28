import 'attributes_model.dart';

class RentalItemModel {
  final Attribute attribute;
  int? selectedAttributeId;
  int quantity;

  RentalItemModel({
    required this.attribute,
    this.selectedAttributeId,
    this.quantity = 1,
  });

  int get id => attribute.id;
  String get name => attribute.name;
  int get price => attribute.priceHour;
  int get stock => attribute.stock;
  int get fieldId => attribute.fkFieldId;
}
