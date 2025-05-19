# Tích hợp UVC Camera trong Flutter

Hướng dẫn này mô tả cách tích hợp camera UVC (USB Video Class) vào ứng dụng Flutter thông qua native code Android.

## Các bước đã thực hiện

1. **Thêm phụ thuộc vào build.gradle**
   - Thêm serenegiant:common và serenegiant:usbcameracommon
   - Thêm androidx.appcompat và androidx.localbroadcastmanager

2. **Tạo các lớp native Android**
   - UVCCameraHelper: Lớp trung tâm để xử lý camera UVC
   - UVCCameraViewFactory & UVCCameraView: Lớp hiển thị camera trong Flutter
   - UVCCameraPlugin: Lớp quản lý giao tiếp Flutter với Android thông qua MethodChannel

3. **Cập nhật MainActivity**
   - Đăng ký UVCCameraPlugin
   - Đảm bảo xử lý sự kiện USB

4. **Tạo các lớp Flutter**
   - UVCCameraController: Lớp quản lý giao tiếp với native code
   - UVCCameraView: Hiển thị camera
   - UVCCameraScreen: Màn hình demo cho camera UVC

5. **Cập nhật Manifest**
   - Thêm quyền USB
   - Thêm bộ lọc USB cho các thiết bị camera phổ biến

## Cách sử dụng

Để sử dụng camera UVC trong ứng dụng:

1. **Kết nối camera UVC** vào thiết bị Android qua cáp OTG

2. **Mở màn hình Test UVC Camera** từ nút trên màn hình đăng nhập

3. **Tìm thiết bị UVC** trong danh sách và nhấn "Kết nối"

4. **Cho phép quyền truy cập USB** khi được yêu cầu

5. **Camera sẽ hiển thị** trong khu vực preview

## Xử lý lỗi

Nếu gặp lỗi "The RTCVideoRenderer is disposed", đây là do sự cố trong việc quản lý vòng đời của Renderer. Giải pháp:

1. Đảm bảo dừng tất cả các streams trước khi dispose renderer
2. Kiểm tra biến `mounted` trước khi thực hiện các thao tác với camera
3. Sử dụng `_isRendererInitialized` để kiểm tra trạng thái renderer

## Lưu ý khi triển khai

1. **Đảm bảo quyền USB được cấp**: Kiểm tra quyền truy cập thiết bị USB trước khi sử dụng
2. **Xử lý vòng đời**: Giải phóng tài nguyên khi không cần thiết
3. **Hỗ trợ thiết bị**: Camera UVC chỉ hoạt động trên Android, iOS cần giải pháp khác 