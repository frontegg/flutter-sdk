class Social {
  bool? active;
  String? authorizationUrl;
  String? clientId;
  bool? customised;
  String? redirectUrl;
  String? type;
  SocialType? socialType;

  Social.fromJson(Map<dynamic, dynamic> json)
      : active = json['active'],
        authorizationUrl = json['authorizationUrl'],
        clientId = json['clientId'],
        customised = json['customised'],
        redirectUrl = json['redirectUrl'],
        type = json['type'] {
    socialType = setSocialType(type);
  }

  SocialType? setSocialType(String? type) {
    switch (type) {
      case 'github':
        return SocialType.github;
      case 'google':
        return SocialType.google;
      case 'microsoft':
        return SocialType.microsoft;
      case 'facebook':
        return SocialType.facebook;
      case 'gitlab':
        return SocialType.gitlab;
      case 'linkedin':
        return SocialType.linkedin;
      default:
        return null;
    }
  }
}

enum SocialType { github, google, microsoft, facebook, gitlab, linkedin }
