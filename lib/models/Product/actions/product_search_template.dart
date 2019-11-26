import '../../root_object.dart';
import '../attribute.dart';
import '../brand.dart';
import '../category.dart';
import '../product_status.dart';

class ProductSearchTemplate extends RootObject {
  int id;
  String name;
  String keyword;
  double priceFrom;
  double priceTo;
  bool freeShip;
  bool soldOut;

  bool saved; //saved local
  bool create;

  // Brand/category/status need saved as a list of value, instead of single value
  List<Brand> brandObjs;
  List<Category> categoryObjs;
  List<ProductStatus> productStatusObjs;

  List<Attribute> colorAttributeObjs;
  List<Attribute> sizeAttributeObjs;

  //
  bool loadFirstPage;
  int pageSize;

  ProductSearchTemplate(
      {this.id,
      this.name,
      this.keyword,
      this.priceFrom,
      this.priceTo,
      this.freeShip,
      this.soldOut,
      this.brandObjs,
      this.categoryObjs,
      this.colorAttributeObjs,
      this.sizeAttributeObjs,
      this.productStatusObjs,
      this.saved = false,
      this.create = false,
      this.loadFirstPage = true,
      this.pageSize});

  @override
  factory ProductSearchTemplate.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      var colors = json["color_attributes"]?.map((e) => Attribute.fromJSON(e));
      var sizes = json["size_attributes"]?.map((e) => Attribute.fromJSON(e));
      var brands = json["brand_ids"]?.map((e) => Brand.fromJSON(e));
      var categories = json["category_ids"]?.map((e) => Category.fromJSON(e));
      var pStatuses =
          json["product_status"]?.map((e) => ProductStatus.fromJSON(e));

      return new ProductSearchTemplate(
          id: json["id"],
          name: json["name"],
          keyword: json["keyword"],
          priceFrom: json["price_from"]?.toDouble(),
          priceTo: json["price_to"]?.toDouble(),
          freeShip: json["free_ship"] == 1 ? true : false,
          soldOut: json['sold_out'] == 1 ? true : false,
          brandObjs: (brands != null) ? List<Brand>.from(brands) : null,
          categoryObjs:
              (categories != null) ? List<Category>.from(categories) : null,
          colorAttributeObjs:
              (colors != null) ? List<Attribute>.from(colors) : null,
          sizeAttributeObjs:
              (sizes != null) ? List<Attribute>.from(sizes) : null,
          productStatusObjs:
              (pStatuses != null) ? List<ProductStatus>.from(pStatuses) : null,
          saved: true);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'name': keyword ?? "Noname",
        'keyword': keyword,
        'price_from': priceFrom,
        'price_to': priceTo,
        'sold_out': soldOut ?? false,
//        'free_ship': freeShip,
        'brand_ids': brandObjs != null
            ? brandObjs.map((b) => b.id.toString()).join(',')
            : null,
        'category_ids': categoryObjs != null
            ? categoryObjs.map((c) => c.id.toString()).join(',')
            : null,
        'product_status_ids': productStatusObjs != null
            ? productStatusObjs.map((c) => c.id.toString()).join(',')
            : null,
        'color_attribute_ids': colorAttributeObjs != null
            ? colorAttributeObjs.map((e) => e.id.toString()).join(',')
            : null,
        'size_attribute_ids': sizeAttributeObjs != null
            ? sizeAttributeObjs.map((e) => e.id.toString()).join(',')
            : null,
      };
}
