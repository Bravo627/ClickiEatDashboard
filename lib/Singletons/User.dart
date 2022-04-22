import 'package:flutter/material.dart';

class User {
  late String _name;
  late String _emailAddress;
  late String _hostel;
  late Image _profilePic;

  User._();
  static User user = User._();

  static User get instance {
    return user;
  }

  String getEmailAddress() => _emailAddress;
  String getHostel() => _hostel;
  String getName() => _name;
  Image getProfilePic() => _profilePic;

  void setEmailAddress(String emailAddress) {
    _emailAddress = emailAddress;
  }

  void setHostel(String hostel) {
    _hostel = hostel;
  }

  void setName(String name) {
    _name = name;
  }

  void setProfilePic(Image image) {
    _profilePic = image;
  }
}
