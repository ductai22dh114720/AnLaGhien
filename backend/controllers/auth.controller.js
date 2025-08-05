// controllers/auth.controller.js
const User = require('../models/user.model');
const Wallet = require('../models/wallet.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

// Khởi tạo client với ID từ file .env
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

exports.signup = async (req, res) => {
  try {
    const { name, email, password, phone, address, dob, gender } = req.body;

    // 1. Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email đã được sử dụng.' });
    }

    // Chuyển đổi dob từ "dd/MM/yyyy" sang Date object
    // Lưu ý: Cần xử lý cẩn thận múi giờ
    let dobDate = null;
    if (dob && typeof dob === 'string') {
      const parts = dob.split('/');
      if (parts.length === 3) {
        // parts[1] - 1 vì tháng trong JavaScript bắt đầu từ 0
        dobDate = new Date(Date.UTC(parts[2], parts[1] - 1, parts[0]));
      }
    }

    // 2. Mã hóa mật khẩu
    const hashedPassword = await bcrypt.hash(password, 12);

    // 3. Tạo user mới
    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      phone,
      address,
      dob,
      gender,
    });

    // SỬA LẠI Ở ĐÂY
       // 4. Lưu user vào DB và lấy kết quả trả về
       const savedUser = await newUser.save();

       // --- THÊM LOGIC TẠO VÍ ---
       const newWallet = new Wallet({ user: savedUser._id });
       await newWallet.save();
       // --- KẾT THÚC SỬA ĐỔI ---

       res.status(201).json({ message: 'Đăng ký thành công!' });

     } catch (error) {
       console.error("Lỗi khi đăng ký:", error);
       res.status(500).json({ message: 'Đã có lỗi xảy ra.', error: error.message });
     }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Tìm user trong DB
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'Email hoặc mật khẩu không đúng.' });
    }

    // 2. So sánh mật khẩu
    const isPasswordCorrect = await bcrypt.compare(password, user.password);
    if (!isPasswordCorrect) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng.' });
    }

    // SỬA LẠI Ở ĐÂY
          const savedUser = await user.save(); // Lưu user mới và lấy kết quả

          // --- THÊM LOGIC TẠO VÍ ---
          const newWallet = new Wallet({ user: savedUser._id });
          await newWallet.save();
          // --- KẾT THÚC THÊM ---

          user = savedUser; // Gán lại user với thông tin đã lưu (bao gồm _id)
        }
    // 3. Tạo JWT token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' } // Token hết hạn sau 1 giờ
    );
      
    // Không trả về mật khẩu cho client
    const userResult = {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone
    };

    res.status(200).json({ token, user: userResult, message: "Đăng nhập thành công" });

  } catch (error) {
    res.status(500).json({ message: 'Đã có lỗi xảy ra.', error: error.message });
  }
};
// --- THÊM HÀM MỚI NÀY VÀO ---
exports.googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;

    // Xác thực idToken với Google
     const ticket = await client.verifyIdToken({
      idToken,
      audience: [
        process.env.GOOGLE_CLIENT_ID, // 1. Client ID của Web (dành cho backend)
        '204589392826-opp8jtqrblptiq4c2soqogfcnfv7oru7.apps.googleusercontent.com'      // 2. Client ID của Android
      ],
    });

    const { name, email } = ticket.getPayload();

    // Kiểm tra user trong DB
    let user = await User.findOne({ email });

    if (!user) {
      // Nếu user không tồn tại, tạo mới
      // Mật khẩu này chỉ là placeholder vì schema yêu cầu, user không dùng nó.
      const password = email + process.env.JWT_SECRET;
      
      user = new User({
        name,
        email,
        password: password, // Schema yêu cầu, nhưng ta có thể không hash
        phone: 'N/A', 
        address: 'N/A', 
      });
      await user.save();
    }

    // Tạo JWT Token của riêng bạn và trả về cho client
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    const userResult = {
      _id: user._id,
      name: user.name,
      email: user.email,
    };

    res.status(200).json({ token, user: userResult, message: "Đăng nhập Google thành công" });

  } catch (error) {
    console.error("Lỗi xác thực Google:", error);
    res.status(500).json({ message: 'Xác thực Google thất bại.', error: error.message });
  }
};

