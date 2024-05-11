class Event {
  DateTime? date;
  String? name;

  Event({this.date, this.name});

  Event.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(json['date']);
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = date.toString();
    data['name'] = name;
    return data;
  }
}
