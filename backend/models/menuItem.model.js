const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MenuItemSchema = new Schema({
    name: { 
        type: String, 
        required: true 
    },
    description: { 
        type: String 
    },
    price: { 
        type: Number, 
        required: true 
    },
    restaurant: { // Đổi tên từ RestaurantID thành restaurant cho đúng convention
        type: Schema.Types.ObjectId,
        ref: 'Restaurant', // Tham chiếu đến model Restaurant
        required: true
    },
    // Thêm trường ảnh cho món ăn
    imageUrl: {
        type: String
    },
    // Trạng thái còn hàng/hết hàng
    isAvailable: {
        type: Boolean,
        default: true
    }
}, { 
    timestamps: true 
});

module.exports = mongoose.model('MenuItem', MenuItemSchema);