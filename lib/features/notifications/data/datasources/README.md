# 📦 Notifications Data Datasources Layer

> Feature-First Architecture - 알림 데이터 소스 레이어

## 📋 개요

알림 데이터의 실제 소스(Firebase, 로컬 DB, FCM 등)와 직접 통신하는 레이어입니다. Remote와 Local 데이터 소스를 분리하여 관리합니다.

## 🏗️ 구조

```
data/datasources/
├── remote_notification_datasource.dart   # Firebase 원격 데이터 소스
├── local_notification_datasource.dart    # 로컬 캐시 데이터 소스  
├── fcm_datasource.dart                  # FCM 푸시 알림 데이터 소스 (향후)
└── notification_preferences_datasource.dart # 알림 설정 데이터 소스
```

## 📦 구현 예정 파일

### RemoteNotificationDatasource
- **역할**: Firebase Firestore와 직접 통신
- **주요 기능**:
  - 알림 목록 가져오기 (페이지네이션)
  - 단일 알림 조회
  - 알림 생성/업데이트/삭제
  - 실시간 알림 스트림
  - 만료된 알림 정리

### LocalNotificationDatasource  
- **역할**: Hive를 사용한 로컬 캐싱
- **주요 기능**:
  - 알림 캐싱 및 조회
  - 읽음 상태 로컬 업데이트
  - 캐시 만료 관리 (30분)
  - 오프라인 지원

### FCMDatasource (향후)
- **역할**: Firebase Cloud Messaging 통합
- **주요 기능**:
  - FCM 토큰 관리
  - 토픽 구독/해제
  - 푸시 알림 권한
  - 포그라운드/백그라운드 메시지 처리

### NotificationPreferencesDatasource
- **역할**: 사용자 알림 설정 관리
- **주요 기능**:
  - 알림 타입별 on/off
  - 알림음 설정
  - 방해금지 시간대

## 🔌 의존성

- `cloud_firestore`: Firebase 데이터베이스
- `hive`: 로컬 캐싱
- `firebase_messaging`: FCM (향후)
- Core 에러 처리 (`/core/errors/`)

## ⚡ 성능 최적화

- **배치 작업**: Firestore batch operations
- **캐시 전략**: 30분 캐시 만료
- **페이지네이션**: 20개씩 lazy loading
- **인덱싱**: Firestore 복합 인덱스

## ✅ 체크리스트

### 구현 완료
- [ ] RemoteNotificationDatasource
- [ ] LocalNotificationDatasource
- [ ] 캐시 만료 로직
- [ ] 에러 처리

### 향후 구현
- [ ] FCMDatasource
- [ ] NotificationPreferencesDatasource
- [ ] 오프라인 동기화
- [ ] 백그라운드 동기화

---

*Feature-First Architecture의 일부로 작성됨*
*최종 업데이트: 2025-08-25*