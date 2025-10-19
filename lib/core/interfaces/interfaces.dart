/// Core interfaces for cross-feature dependency isolation
/// 
/// 이 파일은 Clean Architecture의 원칙에 따라 피처 간 의존성을 격리하기 위한
/// 공통 인터페이스들을 내보냅니다.
/// 
/// 목적:
/// - 의존성 역전 원칙(DIP) 적용
/// - 피처 간 결합도 최소화
/// - 테스트 가능성 향상
/// - 유지보수성 개선

// ===== Common Interfaces =====
export 'common/i_content_model.dart';

// ===== Feature Service Interfaces =====
export 'features/i_post_service.dart';
export 'features/i_vote_service.dart';