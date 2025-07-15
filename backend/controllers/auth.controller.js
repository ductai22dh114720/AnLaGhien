// controllers/auth.controller.js
const User = require('../models/user.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.signup = async (req, res) => {
  try {
    const { name, email, password, phone, address, dob, gender } = req.body;

    // 1. Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email đã được sử dụng.' });
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

    // 4. Lưu user vào DB
    await newUser.save();

    res.status(201).json({ message: 'Đăng ký thành công!' });

  } catch (error) {
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