// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// [수정] 중복되고 오타가 있던 import 구문을 하나로 정리합니다.
import 'package:cloud_firestore/cloud_firestore.dart';

class ProcessingWaitView extends StatelessWidget {
  const ProcessingWaitView({
    Key? key,
    required this.videoDocRef,
    this.width,
    this.height,
  }) : super(key: key);

  final DocumentReference videoDocRef;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: StreamBuilder<DocumentSnapshot>(
        stream: videoDocRef.snapshots(),
        builder: (context, snapshot) {
          bool isCompleted = false;
          String errorMessage = '';

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                isCompleted = (data['status'] == 'encoded' &&
                    (data['url'] as String?)?.isNotEmpty == true);

                if (data['status'] == 'failed') {
                  errorMessage = data['error'] ?? '알 수 없는 오류가 발생했습니다.';
                }
              }
            }
          }

          if (isCompleted || errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!ModalRoute.of(context)!.isCurrent) {
                return;
              }

              if (isCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ 영상이 성공적으로 처리되었습니다!')));

                int popCount = 0;
                Navigator.of(context).popUntil((_) => popCount++ >= 3);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('❌ 처리 실패: $errorMessage'),
                  duration: Duration(seconds: 5),
                ));
                Navigator.of(context).pop();
              }
            });
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  '영상을 처리하고 있습니다.\n잠시만 기다려 주세요...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
