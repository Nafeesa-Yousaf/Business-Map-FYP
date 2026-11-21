import 'package:firebase_auth/firebase_auth.dart';

class UserProfileModel {
  final String uid;
  final String? name;
  final String? email;
  final String? imageUrl;

  UserProfileModel({
    required this.uid,
    this.name,
    this.email,
    this.imageUrl,
  });

  factory UserProfileModel.fromFirebaseUser(User user) {
    return UserProfileModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      imageUrl: user.photoURL,
    );
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? imageUrl,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
