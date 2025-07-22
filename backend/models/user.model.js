const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UserSchema = new Schema({
    name: { 
        type: String, 
        required: true 
    },
    email: { 
        type: String, 
        required: true, 
        unique: true,
        trim: true, // Bỏ khoảng trắng thừa
        lowercase: true // Luôn lưu email ở dạng chữ thường
    },
    password: { 
        type: String, 
        required: true 
    },
    phone: { 
        type: String, 
        required: true 
    },
    address: { 
        type: String, 
        required: true 
    },
    role: {
        type: String,
        enum: ['customer', 'delivery_personnel', 'admin'], // Các vai trò có thể có
        default: 'customer' // Mặc định là khách hàng
    },
    // Các trường dành riêng cho người giao hàng
    vehicle: {
        type: Schema.Types.ObjectId,
        ref: 'Vehicle' // Tham chiếu đến model Vehicle
    },
    availabilityStatus: {
        type: String,
        enum: ['available', 'unavailable', 'on_delivery'],
        default: 'unavailable'
    }
}, { 
    timestamps: true // Tự động thêm createdAt và updatedAt
});

module.exports = mongoose.model('User', UserSchema);