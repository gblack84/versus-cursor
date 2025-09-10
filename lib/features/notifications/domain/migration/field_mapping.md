# Notification Field Mapping Table

## 기존 NotificationsModel → 새 Domain Models 매핑

### 공통 필드 (All Notifications)
| 기존 필드 | 새 Domain 필드 | 타입 변경 | 비고 |
|----------|--------------|----------|------|
| notificationId | id | String | 필드명 변경 |
| userId | userId | String | 유지 |
| type | type | String → NotificationType | Enum으로 변경 |
| content | content | String | 유지 |
| title | title | String | 유지 |
| message | content | String | message와 content 통합 |
| createdAt | createdAt | Timestamp → DateTime | Firebase 타입 제거 |
| read | isRead | bool | 필드명 변경 |
| expiryTime | expiryTime | Timestamp → DateTime | Firebase 타입 제거 |
| status | - | String | metadata로 이동 |
| completedAt | readAt | Timestamp → DateTime | 의미 변경 |

### VoteNotification 전용 필드
| 기존 필드 | 새 Domain 필드 | 타입 변경 | 비고 |
|----------|--------------|----------|------|
| sourceId | postId | String | 필드명 변경 |
| postId | postId | String | 유지 |
| postTitle | postTitle | String | 유지 |
| postContent | postContent | String | 유지 |
| postDescription | postDescription | String? | 유지 |
| imageUrlsA | voteOptions.optionAImageUrls | List<String> | VoteOptions로 이동 |
| imageUrlsB | voteOptions.optionBImageUrls | List<String> | VoteOptions로 이동 |
| textA | voteOptions.optionATitle | String | VoteOptions로 이동 |
| textB | voteOptions.optionBTitle | String | VoteOptions로 이동 |
| aspectRatioA | voteOptions.optionAAspectRatio | double? | VoteOptions로 이동 |
| aspectRatioB | voteOptions.optionBAspectRatio | double? | VoteOptions로 이동 |
| voteStartTime | voteStartTime | Timestamp → DateTime | Firebase 타입 제거 |
| voteEndTime | voteEndTime | Timestamp → DateTime | Firebase 타입 제거 |
| votesA | currentVotesA | int? | 필드명 변경 |
| votesB | currentVotesB | int? | 필드명 변경 |
| targetAudience | targetAudience | List<String> → String? | 타입 변경 |

### SocialNotification 전용 필드
| 기존 필드 | 새 Domain 필드 | 타입 변경 | 비고 |
|----------|--------------|----------|------|
| fromUserId | fromUserId | String | 신규 추가 |
| fromUserName | fromUserName | String | 신규 추가 |
| profileImageUrl | fromUserProfileUrl | String? | 필드명 변경 |
| relatedPostId | relatedPostId | String? | 신규 추가 |
| relatedCommentId | relatedCommentId | String? | 신규 추가 |
| interactionType | actionType | String → SocialActionType | Enum으로 변경 |
| interactionCount | interactionCount | int? | 신규 추가 |

### SystemNotification 전용 필드
| 기존 필드 | 새 Domain 필드 | 타입 변경 | 비고 |
|----------|--------------|----------|------|
| actionUrl | actionUrl | String? | 신규 추가 |
| actionButtons | actionButtons | Map<String, String>? | 신규 추가 |
| iconUrl | iconUrl | String? | imageUrl에서 변경 |
| isDismissible | isDismissible | bool | 신규 추가 |

### 제거된 필드
| 기존 필드 | 이유 |
|----------|------|
| location (LatLng) | Firebase 타입, 사용되지 않음 |
| reference (DocumentReference) | Firebase 의존성 |
| ffRef | FlutterFlow 전용 |
| firestoreUtilData | Firebase 내부 데이터 |

## 타입별 알림 분류 로직

```dart
// 기존 type 필드 값 → 새 도메인 모델 매핑
switch (oldType) {
  case 'votingRequest':
    return VoteNotification(...);
  case 'postLiked':
  case 'commentAdded':  
  case 'friendRequest':
    return SocialNotification(...);
  case 'systemAlert':
  case 'maintenance':
    return SystemNotification(...);
  default:
    return SystemNotification(...); // 기본값
}
```

## 마이그레이션 주의사항

1. **Timestamp → DateTime 변환**
   - Firebase Timestamp.toDate() 메서드 사용
   - UTC 시간대 유지

2. **List<String> targetAudience → String?**
   - 첫 번째 요소만 사용하거나
   - 'quick', 'public', 'custom' 등 단일 값으로 변환

3. **LatLng 제거**
   - 위치 정보가 필요한 경우 metadata에 저장
   - lat/lng를 별도 double 필드로 저장

4. **Reference 제거**
   - ID만 저장하여 참조
   - Repository에서 ID로 조회

5. **Status 필드**
   - metadata Map에 포함시켜 유연성 확보
   - 필요시 별도 enum으로 정의