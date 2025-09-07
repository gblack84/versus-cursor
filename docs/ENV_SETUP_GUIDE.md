# Environment Setup Guide / 환경 설정 가이드

## 🚀 Quick Start / 빠른 시작

### 1. Local Development / 로컬 개발
```bash
# 1. Copy example file / 예제 파일 복사
cp .env.example .env

# 2. Fill in your API keys / API 키 입력
# Edit .env file with your actual values
```

### 2. Required Environment Variables / 필수 환경 변수

```env
# Firebase Configuration / Firebase 설정
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_APP_ID=your_app_id_here

# External APIs / 외부 API
PERSPECTIVE_API_KEY=your_perspective_api_key_here
ALGOLIA_APP_ID=your_algolia_app_id_here
ALGOLIA_API_KEY=your_algolia_api_key_here

# Optional / 선택사항
DEFAULT_CHARACTER_IMAGE_URL=https://your-default-image-url
ENVIRONMENT=development
DEBUG=true
```

## 🔧 CI/CD Configuration / CI/CD 설정

### GitHub Actions
```yaml
# .github/workflows/build.yml
env:
  FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
  FIREBASE_PROJECT_ID: ${{ secrets.FIREBASE_PROJECT_ID }}
  PERSPECTIVE_API_KEY: ${{ secrets.PERSPECTIVE_API_KEY }}
```

### Firebase Hosting
```bash
# Set environment variables in Firebase
firebase functions:config:set \
  firebase.api_key="your_key" \
  firebase.project_id="your_project"
```

## 🧪 Verification / 검증

### Run verification script / 검증 스크립트 실행
```bash
flutter run --dart-define=ENV_CHECK=true
```

### Check in main.dart / main.dart에서 확인
```dart
// The app will validate on startup
// 앱 시작 시 자동 검증
if (!EnvironmentConfig.validateConfiguration()) {
  print('❌ Environment configuration is invalid.');
}
```

## ⚠️ Security Notes / 보안 주의사항

1. **NEVER commit .env file** / .env 파일 절대 커밋 금지
2. **Keep API keys secret** / API 키 비밀 유지
3. **Rotate keys regularly** / 정기적으로 키 교체
4. **Use different keys for production** / 프로덕션용 별도 키 사용

## 📱 Platform-Specific Setup / 플랫폼별 설정

### iOS
No additional setup required. Environment variables are loaded at runtime.
추가 설정 불필요. 환경 변수는 런타임에 로드됩니다.

### Android
No additional setup required. Environment variables are loaded at runtime.
추가 설정 불필요. 환경 변수는 런타임에 로드됩니다.

### Web
For web deployment, ensure environment variables are set in your hosting platform.
웹 배포 시, 호스팅 플랫폼에서 환경 변수를 설정하세요.

## 🐛 Troubleshooting / 문제 해결

### Missing .env file / .env 파일 없음
```
Error: Unable to load asset: .env
Solution: Create .env file from .env.example
```

### Invalid API key / 잘못된 API 키
```
Error: Firebase initialization error
Solution: Verify your API keys are correct
```

### Environment not loading / 환경 변수 로드 실패
```
Error: EnvironmentConfig not initialized
Solution: Ensure EnvironmentConfig.init() is called in main()
```

## 📞 Support / 지원

If you need help with environment setup:
환경 설정에 도움이 필요하면:

1. Check .env.example for reference / .env.example 참조
2. Verify all required variables are set / 모든 필수 변수 설정 확인
3. Run validation check / 검증 확인 실행