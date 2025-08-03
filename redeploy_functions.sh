#!/bin/bash

echo "🚀 Firebase Functions 재배포 시작..."
echo ""

# Functions 재배포 (전체)
echo "📦 모든 Functions 재배포 중..."
firebase deploy --only functions

echo ""
echo "✅ 재배포 완료!"
echo ""
echo "🔍 다음 사항을 확인하세요:"
echo "1. Firebase Console에서 Functions 로그 확인"
echo "2. 모든 Functions가 정상적으로 실행 중인지 확인"
echo "3. 최근 에러 로그가 있는지 확인"