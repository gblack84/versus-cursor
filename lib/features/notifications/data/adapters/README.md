# 📦 Notifications Data Services Layer

> Feature-First Architecture - 알림 서비스 구현 레이어

## 📋 개요

알림 기능의 핵심 비즈니스 로직과 서비스 구현을 담당하는 레이어입니다.

## 🏗️ 구조

```
data/services/
├── notification_service.dart          # 알림 핵심 서비스
├── global_notification_manager.dart   # 전역 알림 관리
├── target_audience_service.dart       # 타겟 오디언스 서비스
├── notification_queue_service.dart    # 알림 큐 관리 (향후)
└── fcm_service.dart                  # FCM 서비스 (향후)
```

## 📦 구현 파일

### NotificationService
- **역할**: 알림 표시 및 관리
- **주요 기능**:
  - 실시간 알림 수신
  - 알림 다이얼로그 표시
  - 알림 상태 업데이트
  - 투표 알림 처리

### GlobalNotificationManager
- **역할**: 전역 알림 큐 관리
- **주요 기능**:
  - 알림 큐 관리
  - 순차적 알림 표시
  - 중복 알림 방지
  - 사용자 반응 추적

### TargetAudienceService
- **역할**: AI 기반 타겟 오디언스 선택
- **주요 기능**:
  - 사용자 프로필 분석
  - 콘텐츠 매칭
  - 타겟 모드 처리 (quick/public/custom)
  - 관련성 점수 계산

### NotificationQueueService (향후)
- **역할**: 알림 큐 최적화
- **주요 기능**:
  - 우선순위 관리
  - 배치 처리
  - 스로틀링

### FCMService (향후)
- **역할**: FCM 통합 서비스
- **주요 기능**:
  - 푸시 알림 처리
  - 백그라운드 메시지
  - 토픽 관리

## 🔌 의존성

- Firebase Functions 연동
- Firestore 실시간 리스너
- AI/ML 서비스 (Gemini)
- 알림 UI 컴포넌트

## ✅ 체크리스트

### 구현 완료
- [x] NotificationService
- [x] GlobalNotificationManager
- [x] TargetAudienceService

### 향후 구현
- [ ] NotificationQueueService
- [ ] FCMService
- [ ] 알림 우선순위 시스템

---

*Feature-First Architecture의 일부로 작성됨*
*최종 업데이트: 2025-08-25*