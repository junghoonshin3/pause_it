#!/bin/bash

# DEV 환경 빌드 스크립트
# 환경변수는 .env 파일에서 자동 로드됨
# 사용법: ./scripts/build_dev.sh

flutter build apk --release --flavor dev -t lib/main_dev.dart
