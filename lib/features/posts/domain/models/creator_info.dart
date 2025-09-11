import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing creator information for a post
class CreatorInfo extends Equatable {
  const CreatorInfo({
    this.userid = '',
    this.uid = '',
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    this.createdTime,
  });

  final String userid;
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final DateTime? createdTime;

  /// Creates a copy of this creator info with the given fields replaced with new values
  CreatorInfo copyWith({
    String? userid,
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdTime,
  }) {
    return CreatorInfo(
      userid: userid ?? this.userid,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  /// Converts this creator info to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'created_time': createdTime,
    };
  }

  /// Creates creator info from a Firestore document
  factory CreatorInfo.fromJson(Map<String, dynamic> json) {
    return CreatorInfo(
      userid: json['userid'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? '',
      photoUrl: json['photo_url'] ?? json['photoUrl'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      createdTime:
          (json['created_time'] ?? json['createdTime'] as Timestamp?)?.toDate(),
    );
  }

  /// Checks if this creator has complete profile information
  bool get hasCompleteProfile =>
      displayName.isNotEmpty && photoUrl.isNotEmpty && uid.isNotEmpty;

  /// Gets display name or fallback to email
  String get displayNameOrEmail => displayName.isNotEmpty ? displayName : email;

  @override
  List<Object?> get props => [
        userid,
        uid,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        createdTime,
      ];

  @override
  String toString() => 'CreatorInfo(displayName: $displayName, uid: $uid)';
}
