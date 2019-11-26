class Revenue {
  double revenue;

  int quantitySold;
  int quantityRefunded;
  int quantityBought;

  Revenue({
    this.revenue = 0,
    this.quantityBought = 0,
    this.quantitySold = 0,
    this.quantityRefunded = 0,
  });

  @override
  factory Revenue.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return Revenue(
          revenue: json["revenue"].toDouble(),
          quantitySold: json['quantity_sold'],
          quantityBought: json['quantity_bought'],
          quantityRefunded: json['quantity_refunded']);
    }
    return null;
  }
}

class RevenueChart {
  int month;
  int year;
  double amount;

  RevenueChart({
    this.month = 0,
    this.year = 0,
    this.amount = 0,
  });

  @override
  factory RevenueChart.fromJSON(Map<String, dynamic> json) {
    if (json != null) {
      return RevenueChart(
        month: json["month"],
        year: json["year"],
        amount: json["amount"].toDouble(),
      );
    }
    return null;
  }
}
