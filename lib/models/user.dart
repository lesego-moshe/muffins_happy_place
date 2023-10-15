class CurrentUser {
  String firstName;
  String lastName;
  String userName;
  List<String> cards;
  String uid;
  String bio;
  String userAvatar;

  CurrentUser(
      {this.firstName,
      this.lastName,
      this.userName,
      this.cards,
      this.uid,
      this.userAvatar,
      this.bio});

  CurrentUser.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    userName = json['userName'];
    cards = json['cards'].cast<String>();
    uid = json['uid'];
    bio = json['bio'];
    userAvatar = json['userAvatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['userName'] = this.userName;
    data['cards'] = this.cards;
    data['uid'] = this.uid;
    data['bio'] = this.bio;
    return data;
  }
}