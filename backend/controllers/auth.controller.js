//// File: backend/controllers/auth.controller.js
//
//const User = require('../models/user.model');
//const Wallet = require('../models/wallet.model');
//const bcrypt = require('bcryptjs');
//const jwt = require('jsonwebtoken');
//const { OAuth2Client } = require('google-auth-library');
//
//const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
//
//exports.signup = async (req, res) => {
//  try {
//    const { name, email, password, phone, address, dob, gender } = req.body;
//
//    const existingUser = await User.findOne({ email });
//    if (existingUser) {
//      return res.status(400).json({ message: 'Email đã được sử dụng.' });
//    }
//
//    let dobDate = null;
//    if (dob && typeof dob === 'string') {
//      const parts = dob.split('/');
//      if (parts.length === 3) {
//        dobDate = new Date(Date.UTC(parts[2], parts[1] - 1, parts[0]));
//      }
//    }
//
//    const hashedPassword = await bcrypt.hash(password, 12);
//
//    const newUser = new User({
//      name, email, password: hashedPassword, phone, address,
//      dob: dobDate, // Sử dụng dobDate đã được xử lý
//      gender,
//    });
//
//    const savedUser = await newUser.save();
//
//    // Tự động tạo ví cho user mới
//    const newWallet = new Wallet({ user: savedUser._id });
//    await newWallet.save();
//
//    res.status(201).json({ message: 'Đăng ký thành công!' });
//
//  } catch (error) {
//    console.error("Lỗi khi đăng ký:", error);
//    res.status(500).json({ message: 'Đã có lỗi xảy ra.', error: error.message });
//  }
//};
//
//exports.login = async (req, res) => {
//  try {
//    const { email, password } = req.body;
//
//    const user = await User.findOne({ email });
//    if (!user) {
//      return res.status(404).json({ message: 'Email hoặc mật khẩu không đúng.' });
//    }
//
//    const isPasswordCorrect = await bcrypt.compare(password, user.password);
//    if (!isPasswordCorrect) {
//      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng.' });
//    }
//
//    // LOGIC TẠO VÍ ĐÃ ĐƯỢC XÓA KHỎI ĐÂY VÌ NÓ KHÔNG CẦN THIẾT
//
//    const token = jwt.sign(
//      { userId: user._id, email: user.email },
//      process.env.JWT_SECRET,
//      { expiresIn: '1h' }
//    );
//
//    const userResult = {
//        _id: user._id,
//        name: user.name,
//        email: user.email,
//        phone: user.phone
//    };
//
//    res.status(200).json({ token, user: userResult, message: "Đăng nhập thành công" });
//
//  } catch (error) {
//    res.status(500).json({ message: 'Đã có lỗi xảy ra.', error: error.message });
//  }
//};
//
//exports.googleLogin = async (req, res) => {
//  try {
//    const { idToken } = req.body;
//
//    const ticket = await client.verifyIdToken({
//      idToken,
//      audience: [
//        process.env.GOOGLE_CLIENT_ID,
//        '204589392826-opp8jtqrblptiq4c2soqogfcnfv7oru7.apps.googleusercontent.com'
//      ],
//    });
//
//    const { name, email } = ticket.getPayload();
//    let user = await User.findOne({ email });
//
//    if (!user) {
//      const password = email + process.env.JWT_SECRET;
//
//      const newUser = new User({
//        name,
//        email,
//        password: password, // Mật khẩu placeholder
//        phone: 'N/A',
//        address: 'N/A',
//      });
//
//      const savedUser = await newUser.save();
//
//      // Tự động tạo ví cho user mới từ Google
//      const newWallet = new Wallet({ user: savedUser._id });
//      await newWallet.save();
//
//      user = savedUser; // Gán lại user với _id mới
//    }
//
//    const token = jwt.sign(
//      { userId: user._id, email: user.email },
//      process.env.JWT_SECRET,
//      { expiresIn: '1h' }
//    );
//
//    const userResult = {
//      _id: user._id,
//      name: user.name,
//      email: user.email,
//    };
//
//    res.status(200).json({ token, user: userResult, message: "Đăng nhập Google thành công" });
//
//  } catch (error) {
//    console.error("Lỗi xác thực Google:", error);
//    res.status(500).json({ message: 'Xác thực Google thất bại.', error: error.message });
//  }
//};
// backend/controllers/auth.controller.js

const User = require('../models/user.model');
const Wallet = require('../models/wallet.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Helper function để tạo JWT token.
 * Luôn bao gồm userId, email, và role.
 * @param {object} user - Đối tượng user từ Mongoose
 * @returns {string} - Chuỗi JWT token
 */
const generateToken = (user) => {
    return jwt.sign(
        { userId: user._id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '1d' } // Tăng thời gian hết hạn lên 1 ngày
    );
};

// --- HÀM ĐĂNG KÝ ---
exports.signup = async (req, res) => {
    try {
        const { name, email, password, phone, address, dob, gender } = req.body;

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'Email đã được sử dụng.' });
        }

        // Xử lý ngày sinh an toàn hơn
        let dobDate = null;
        if (dob && typeof dob === 'string') {
            const parts = dob.split('/');
            if (parts.length === 3) {
                // new Date(year, monthIndex, day)
                dobDate = new Date(parts[2], parts[1] - 1, parts[0]);
            }
        }

        const hashedPassword = await bcrypt.hash(password, 12);
        const newUser = new User({
            name, email, password: hashedPassword, phone, address, dob: dobDate, gender,
            // Người dùng đăng ký mới mặc định là 'customer'
            role: 'customer'
        });

        const savedUser = await newUser.save();

        // Tự động tạo ví cho user mới
        const newWallet = new Wallet({ user: savedUser._id });
        await newWallet.save();

        res.status(201).json({ message: 'Đăng ký thành công!' });
    } catch (error) {
        console.error("Lỗi khi đăng ký:", error);
        res.status(500).json({ message: 'Đã có lỗi xảy ra khi đăng ký.', error: error.message });
    }
};


// --- HÀM ĐĂNG NHẬP BẰNG EMAIL/PASSWORD ---
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Tìm người dùng trong database
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng.' });
        }

        // So sánh mật khẩu
        const isPasswordCorrect = await bcrypt.compare(password, user.password);
        if (!isPasswordCorrect) {
            return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng.' });
        }

        // Tạo token
        const token = generateToken(user);

        // Chuẩn bị dữ liệu user để trả về (không bao gồm mật khẩu)
        const userToReturn = user.toObject();
        delete userToReturn.password;

        res.status(200).json({ token, user: userToReturn });

    } catch (error) {
        console.error("Lỗi khi đăng nhập:", error);
        res.status(500).json({ message: 'Đã có lỗi xảy ra khi đăng nhập.', error: error.message });
    }
};


// --- HÀM ĐĂNG NHẬP BẰNG GOOGLE ---
exports.googleLogin = async (req, res) => {
    try {
        const { idToken } = req.body;

        const ticket = await client.verifyIdToken({
            idToken,
            audience: process.env.GOOGLE_CLIENT_ID, // Chỉ cần Client ID của server
        });
        const { name, email, picture } = ticket.getPayload();

        // Tìm xem user đã tồn tại trong DB chưa
        let user = await User.findOne({ email });

        if (!user) {
            // Nếu user chưa tồn tại, tạo mới
            const password = `${email}${process.env.JWT_SECRET}`;
            const hashedPassword = await bcrypt.hash(password, 12);

            user = new User({
                name,
                email,
                password: hashedPassword, // Mã hóa mật khẩu placeholder
                avatarUrl: picture,
                role: 'customer' // Người dùng mới luôn là customer
            });
            await user.save();

            // Tạo ví cho người dùng mới này
            const newWallet = new Wallet({ user: user._id });
            await newWallet.save();
        }

        // Tạo token dựa trên thông tin user (dù là cũ hay mới)
        const token = generateToken(user);

        // Chuẩn bị dữ liệu user để trả về (không bao gồm mật khẩu)
        const userToReturn = user.toObject();
        delete userToReturn.password;

        res.status(200).json({ token, user: userToReturn });

    } catch (error) {
        console.error("Lỗi xác thực Google:", error);
        res.status(500).json({ message: 'Xác thực Google thất bại.', error: error.message });
    }
};