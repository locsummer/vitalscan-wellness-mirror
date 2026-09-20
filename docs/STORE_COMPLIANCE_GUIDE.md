# Hướng dẫn Kiểm duyệt App Store & Google Play cho Ứng dụng rPPG (Store Compliance Guide)

## 1. Rào cản lớn nhất khi xuất bản app đo sinh trắc bằng Camera
Các ứng dụng đo nhịp tim/chỉ số sức khỏe qua camera thường đối mặt với nguy cơ bị Apple và Google từ chối (Reject) ngay vòng review đầu tiên nếu không tuân thủ nghiêm ngặt quy định về y tế:
- **Apple App Store Review Guideline 1.4.1 (Physical Harm / Medical Hardware & Software):** Yêu cầu ứng dụng liên quan đến sức khỏe/y tế phải cung cấp bằng chứng lâm sàng nếu tuyên bố chẩn đoán hoặc điều trị.
- **Google Play Health Content and Services Policy:** Cấm các ứng dụng đưa ra tuyên bố y khoa sai lệch hoặc không có căn cứ phần cứng/y tế được phê chuẩn.

---

## 2. Các nguyên tắc vàng để Vượt qua Kiểm duyệt (Pass Review)

### 2.1. Phân loại sản phẩm (Product Categorization)
- **Danh mục chính:** **Health & Fitness** (Sức khỏe & Thể hình) hoặc **Lifestyle** (Phong cách sống).
- **Tuyệt đối KHÔNG chọn:** Medical (Y tế) trừ khi bạn là cơ sở y tế có chứng nhận thiết bị y tế (FDA 510(k), CE Class IIa).

### 2.2. Quy tắc ngôn từ (Forbidden vs. Allowed Terminology)
| Tuyệt đối TRÁNH (Gây Reject 100%) | CỤM TỪ ĐƯỢC PHÉP DÙNG (An toàn) |
| :--- | :--- |
| Đo Huyết áp (Blood Pressure: 120/80 mmHg) | Đánh giá mức năng lượng / Tải tim mạch (Cardio Load / Vitality Index) |
| Chẩn đoán rối loạn nhịp tim / Bệnh tim | Theo dõi nhịp tim tham khảo khi tập luyện (Fitness Heart Rate) |
| Phát hiện rung nhĩ (Atrial Fibrillation / Arrhythmia) | Xu hướng biến thiên nhịp tim (HRV Trend for recovery) |
| Đo nồng độ oxy máu SpO2 (nếu camera thường không có LED hồng ngoại chuẩn) | Chỉ số hô hấp ước tính (Estimated Breath Rate for Relaxation) |
| Thiết bị y tế / Medical Diagnosis | Công cụ theo dõi sức khỏe tổng thể (General Wellness & Fitness Tool) |

### 2.3. Bắt buộc có Y tế Disclaimer (Medical Disclaimer) rõ ràng
Bắt buộc phải hiển thị Disclaimer ở 3 vị trí:
1. **Mô tả ứng dụng trên App Store / Google Play:** Ở ngay đoạn đầu tiên của mô tả.
2. **Màn hình Khởi động đầu tiên (First Launch Onboarding Modal):** Bắt buộc người dùng ấn nút "Tôi hiểu và Đồng ý" trước khi vào màn hình quét.
3. **Màn hình Báo cáo kết quả (Scan Summary Screen):** Đặt một banner nhỏ ở chân trang.

#### Mẫu văn bản Disclaimer chuẩn được Apple & Google chấp thuận:
> **"LƯU Ý QUAN TRỌNG VỀ SỨC KHỎE:**
> Ứng dụng này chỉ được thiết kế cho mục đích rèn luyện thể chất và theo dõi sức khỏe tổng thể (General Wellness & Fitness). Ứng dụng **KHÔNG PHẢI LÀ THIẾT BỊ Y TẾ**, không cung cấp chẩn đoán y khoa, không thay thế lời khuyên của bác sĩ chuyên nghiệp và không được sử dụng trong các tình huống cấp cứu y tế. Luôn tham khảo ý kiến bác sĩ hoặc chuyên gia y tế trước khi đưa ra bất kỳ quyết định y tế nào."

### 2.4. Quyền riêng tư & Xử lý hình ảnh khuôn mặt
- Cả Apple và Google đều yêu cầu minh bạch về việc hình ảnh khuôn mặt được xử lý như thế nào.
- Trong App Privacy (App Store Connect) & Data Safety Form (Google Play Console):
  - Khai báo rõ: **Camera feed được xử lý On-Device theo thời gian thực (Real-time On-Device Processing)**.
  - Khẳng định: **Không lưu trữ video, không truyền tải khuôn mặt hoặc dữ liệu sinh trắc học cá nhân lên máy chủ đám mây bên thứ ba**.
