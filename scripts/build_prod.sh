#!/bin/bash

# PROD 환경 빌드 스크립트
# 환경변수는 .env 파일에서 자동 로드됨
# 사용법: ./scripts/build_prod.sh

flutter build apk --release --flavor prod -t lib/main_prod.dart
