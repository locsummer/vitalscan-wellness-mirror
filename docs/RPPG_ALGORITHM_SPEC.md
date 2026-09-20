# Tài liệu kỹ thuật: Thuật toán rPPG & Xử lý tín hiệu quang học thể tích từ xa (rPPG Algorithm Spec)

## 1. Cơ chế hoạt động của rPPG (Remote Photoplethysmography)

Khi tim co bóp, một lượng máu giàu oxy được đẩy vào hệ tuần hoàn ngoại vi. Lớp mao mạch dưới da mặt (đặc biệt ở trán và hai bên má) giãn nở theo chu kỳ tim, làm thay đổi lượng hấp thụ ánh sáng của huyết sắc tố (Hemoglobin).
- **Kênh Xanh lá (Green - 530–570 nm):** Có hệ số hấp thụ Hemoglobin cao nhất trong quang phổ nhìn thấy, phản ánh biến thiên thể tích máu mạnh nhất.
- **Kênh Đỏ & Xanh dương (Red, Blue):** Chứa nhiều thành phần phản xạ gương (specular reflection) và ánh sáng môi trường.

---

## 2. Pipeline xử lý tín hiệu chi tiết

```
Camera Stream (30 FPS)
       │
       ▼
Face Landmark Detection (Vision / ML Kit)
       │
       ▼
ROI Extraction (Forehead & Cheeks)
       │
       ▼
Spatial Pixel Averaging: c(t) = [r(t), g(t), b(t)]^T
       │
       ▼
Temporal Normalization: c_n(t) = c(t) / μ_c(t)
       │
       ▼
POS (Plane-Orthogonal-to-Skin) Projection:
  S_1(t) = G(t) - B(t)
  S_2(t) = G(t) + B(t) - 2*R(t)
  h(t) = S_1(t) + α * S_2(t),  với α = σ(S_1) / σ(S_2)
       │
       ▼
Butterworth Bandpass Filter (0.75 Hz – 3.5 Hz)  ~ [45 – 210 BPM]
       │
       ▼
Power Spectral Density (FFT) & Peak Detection
       │
       ▼
Tính toán chỉ số sinh trắc:
  ├── Heart Rate (HR - BPM) = argmax(PSD) * 60
  ├── HRV (RMSSD, SDNN) từ chuỗi khoảng cách đỉnh R-R
  ├── Respiratory Rate (RR - brpm) từ điều chế biên độ/tần số (0.15–0.4 Hz)
  └── Stress Index & Skin Vitality
```

---

## 3. Công thức toán học cốt lõi

### 3.1. Thuật toán POS (Plane-Orthogonal-to-Skin - Wang et al., 2017)
Thuật toán POS chiếu tín hiệu màu không gian vào một mặt phẳng trực giao với vector phản xạ da để loại bỏ hoàn toàn nhiễu do thay đổi cường độ ánh sáng và dịch chuyển nhỏ của đầu:

1. **Chuẩn hóa cục bộ trong cửa sổ trượt (Sliding Window $L = 30-45$ frames):**
   $$c_n(t) = \frac{c(t)}{\frac{1}{L}\sum_{k=t-L+1}^t c(k)}$$

2. **Chiếu tín hiệu:**
   $$S_1(t) = G_n(t) - B_n(t)$$
   $$S_2(t) = G_n(t) + B_n(t) - 2 R_n(t)$$

3. **Tổng hợp tín hiệu mạch:**
   $$H(t) = S_1(t) + \frac{\sigma(S_1)}{\sigma(S_2)} S_2(t)$$

### 3.2. Bộ lọc dải thông (Bandpass Filtering)
- Tần số cắt dưới: $f_{low} = 0.75\text{ Hz}$ (tương ứng 45 BPM)
- Tần số cắt trên: $f_{high} = 3.5\text{ Hz}$ (tương ứng 210 BPM)
- Sử dụng bộ lọc IIR Butterworth bậc 2/4 hai chiều (Zero-phase filtering) để không làm lệch pha đỉnh nhịp tim.

### 3.3. Đo biến thiên nhịp tim (Heart Rate Variability - HRV)
Dựa trên chuỗi khoảng cách liên nhịp $RR_i$ (đơn vị mili-giây):
- **SDNN (Standard Deviation of NN intervals):**
  $$\text{SDNN} = \sqrt{\frac{1}{N-1}\sum_{i=1}^N (RR_i - \overline{RR})^2}$$
- **RMSSD (Root Mean Square of Successive Differences - Phản ánh hệ đối giao cảm/mức độ phục hồi):**
  $$\text{RMSSD} = \sqrt{\frac{1}{N-1}\sum_{i=1}^{N-1} (RR_{i+1} - RR_i)^2}$$

### 3.4. Ước lượng nhịp thở (Respiration Rate)
Tín hiệu hô hấp điều chế biên độ và tần số của sóng PPG (Respiratory Sinus Arrhythmia - RSA). Áp dụng lọc dải hẹp $0.15\text{ Hz} - 0.40\text{ Hz}$ (9 - 24 lần/phút) trên đường bao của sóng PPG.
