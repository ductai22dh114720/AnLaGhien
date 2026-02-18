// backend/middleware/upload.middleware.js
const multer = require('multer');

// Cấu hình multer để lưu file tạm thời trong bộ nhớ
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

module.exports = upload;