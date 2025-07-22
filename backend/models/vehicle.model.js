const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const VehicleSchema = new Schema({
    type: {
        type: String,
        required: true,
        enum: ['bike', 'car', 'scooter']
    },
    registrationNumber: {
        type: String,
        required: true,
        unique: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Vehicle', VehicleSchema);