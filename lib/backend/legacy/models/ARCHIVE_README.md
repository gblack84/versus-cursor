# Legacy Models Archive
# 레거시 모델 아카이브

> 아카이브 날짜: 2025-01-09  
> Phase 1.1D Migration - Task 1.1.55

## 📦 아카이브 목적

이 디렉토리는 Feature-First Architecture 마이그레이션 과정에서 더 이상 사용되지 않는 레거시 파일들을 보관합니다.

## 📁 아카이브된 파일들

### 문서 파일
- **README.md**: 구 backend/models 아키텍처 설명서
- **MIGRATION_Part3.md**: Phase 1.1 마이그레이션 계획 문서 (완료됨)
- **TEST.md**: 레거시 테스트 전략 문서

### 코드 파일
- **index.dart**: 더 이상 사용되지 않는 export 파일
  - 활성 import 없음
  - Feature-based exports로 대체됨

## ⚠️ 주의사항

- 이 파일들은 참조용으로만 보관됩니다
- 새로운 코드에서는 이 파일들을 import하지 마세요
- 대신 feature-based imports를 사용하세요:
  ```dart
  // ❌ Don't use
  import '/backend/models/index.dart';
  
  // ✅ Use instead
  import '/features/[feature]/domain/models/[model].dart';
  ```

## 🗓️ 삭제 예정

- **예정일**: 2025-06-30 (6개월 후)
- 이 날짜 이후 완전히 삭제될 예정입니다