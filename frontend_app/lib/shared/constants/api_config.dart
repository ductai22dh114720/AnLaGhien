// File: lib/shared/constants/api_config.dart

class ApiConfig {
  // // DÙNG LỆNH ipconfig ĐỂ LẤY IP MỚI NHẤT VÀ DÁN VÀO ĐÂY
  // static const String _ipAddress = "192.168.2.4"; // <-- Sửa IP ở đây

  // // KIỂM TRA LẠI CỔNG BACKEND ĐANG CHẠY (3000 hay 5000?)
  // static const String _port = "5000";

  // URL cơ sở, các file khác sẽ dùng cái này
  // Để test local, dùng: 'http://localhost:5000/api'
  // Để dùng production, dùng: 'https://anlaghien-be.onrender.com/api'
  // static const String baseUrl = 'http://localhost:5000/api';
  static const String baseUrl = 'https://anlaghien-be.onrender.com/api';
  static const String googleApiKey = "AIzaSyDoFrAvPlf5ol0Pune_HNZCgCtNdm-HS9g";
}
