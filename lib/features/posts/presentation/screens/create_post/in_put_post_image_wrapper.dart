import 'package:flutter/material.dart';
import 'create_post_screen.dart';

/// Wrapper widget to redirect to new CreatePostScreen
///
/// This wrapper maintains backward compatibility by keeping the original
/// route name and path, while redirecting to the new Clean Architecture implementation.
class InPutPostImageWrapper extends StatelessWidget {
  const InPutPostImageWrapper({super.key});

  static String routeName = 'InPutPostImage';
  static String routePath = '/inPutPostImage';

  @override
  Widget build(BuildContext context) {
    // 새로운 CreatePostScreen으로 리디렉션
    return const CreatePostScreen();
  }
}