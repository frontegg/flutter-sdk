class SocialType {
  bool? active;
  String? authorizationUrl;
  String? clientId;
  bool? customised;
  String? redirectUrl;
  String? type;

  SocialType.fromJson(Map<dynamic, dynamic> json)
      : active = json['active'],
        authorizationUrl = json['authorizationUrl'],
        clientId = json['clientId'],
        customised = json['customised'],
        redirectUrl = json['redirectUrl'],
        type = json['type'];
}
