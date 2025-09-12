// ==========================================
// VoteCountsAdapter 사용법 예제 - DEPRECATED
// ==========================================
//
// 이 파일은 레거시 VotecountsModel 사용 예제였으나 Clean Architecture 마이그레이션으로 인해 deprecated되었습니다.
// 새로운 Clean Architecture 패턴을 사용하는 예제로 교체가 필요합니다.
//
// TODO: Clean Architecture를 사용하는 새로운 예제 작성
// - Repository 패턴 사용
// - Domain 모델(VoteCounts) 사용  
// - Use Case 패턴 적용

// All imports removed - examples deprecated due to legacy model dependencies
import 'package:flutter/foundation.dart';

/// VoteCountsAdapter 사용법을 보여주는 예제들
/// 
/// DEPRECATED: 레거시 모델 의존성으로 인해 모든 예제가 주석 처리됨
class VoteCountsAdapterExample {
  
  // All examples removed due to legacy VotecountsModel dependencies
  // TODO: Create clean architecture examples using:
  // - IVotingRepository instead of direct Firestore access
  // - VoteCounts domain model instead of VotecountsModel
  // - Proper dependency injection
  
  static void showDeprecationWarning() {
    if (kDebugMode) {
      print('VoteCountsAdapterExample is deprecated.');
      print('Use clean architecture patterns with repository and use cases instead.');
    }
  }
}