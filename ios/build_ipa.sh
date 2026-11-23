#!/bin/bash
set -e

echo "=== Đang build VitalScanMirror iOS cho Sideloadly ==="

# Chuyển vào thư mục chứa script
cd "$(dirname "$0")"

# Xóa build cũ nếu có
rm -rf build Payload VitalScanMirror.ipa

echo "--> Đang biên dịch mã nguồn Swift/SwiftUI..."
xcodebuild -project VitalScanMirror.xcodeproj \
  -scheme VitalScanMirror \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

echo "--> Đang đóng gói .app vào file .ipa..."
mkdir -p Payload
cp -r build/Build/Products/Release-iphoneos/VitalScanMirror.app Payload/
zip -qr VitalScanMirror.ipa Payload

# Dọn dẹp tạm
rm -rf Payload build

echo "=== THÀNH CÔNG! File IPA được lưu tại: $(pwd)/VitalScanMirror.ipa ==="
echo "Bạn có thể kéo thả file này vào Sideloadly trên Windows để cài đặt lên iPhone."
