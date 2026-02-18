const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const VehicleSchema = new Schema({
    type: {
        type: String,
        required: true,
        enum: {
            values: ['bike', 'car', 'scooter'],
            message: '{VALUE} is not a supported vehicle type'
        }
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