// File: backend/controllers/payment.controller.js

const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

// TODO: Sau này, bạn sẽ tạo các bản ghi Transaction trong DB ở đây

exports.createVnpayPayment = async (req, res) => {
    try {
        // Lấy địa chỉ IP của client
        const ipAddr = req.headers['x-forwarded-for'] ||
            req.connection.remoteAddress ||
            req.socket.remoteAddress ||
            req.connection.socket.remoteAddress;

        const tmnCode = process.env.VNPAY_TMN_CODE;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        let vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL; // URL Render của bạn

        const date = new Date();
        const createDate = moment(date).format('YYYYMMDDHHmmss');

        const orderId = moment(date).format('DDHHmmss');
        const { amount, orderDescription = 'Nap tien vao vi', orderType = 'topup', bankCode = '' } = req.body;

        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = tmnCode;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_TxnRef'] = orderId;
        vnp_Params['vnp_OrderInfo'] = orderDescription;
        vnp_Params['vnp_OrderType'] = orderType;
        vnp_Params['vnp_Amount'] = amount * 100; // VNPay yêu cầu nhân 100
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_CreateDate'] = createDate;
        if (bankCode !== '') {
            vnp_Params['vnp_BankCode'] = bankCode;
        }

        // Sắp xếp các tham số theo thứ tự ABC
        vnp_Params = Object.keys(vnp_Params).sort().reduce(
            (obj, key) => {
                obj[key] = vnp_Params[key];
                return obj;
            },
            {}
        );

        const signData = querystring.stringify(vnp_Params, { encode: false });
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest("hex");

        vnp_Params['vnp_SecureHash'] = signed;

        vnpUrl += '?' + querystring.stringify(vnp_Params, { encode: true });

        // Trả về URL thanh toán cho client
        res.status(200).json({ paymentUrl: vnpUrl });

    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};

// Hàm xử lý kết quả trả về từ VNPay (sau khi người dùng thanh toán)
exports.handleVnpayReturn = (req, res) => {
    // TODO:
    // 1. Lấy các tham số từ req.query.
    // 2. Xác thực chữ ký (vnp_SecureHash) để đảm bảo dữ liệu không bị thay đổi.
    // 3. Kiểm tra vnp_ResponseCode để xem giao dịch có thành công không (00 là thành công).
    // 4. Nếu thành công, tìm và cập nhật trạng thái Transaction trong DB.
    // 5. Cộng tiền vào Wallet của user.
    // 6. Trả về một trang HTML đơn giản để thông báo cho người dùng.

    console.log("VNPay return data:", req.query);
    res.send("<h1>Giao dịch đang được xử lý...</h1><p>Bạn có thể đóng cửa sổ này.</p>");
};