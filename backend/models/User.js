const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true, minlength: 6 },
  phone: { type: String, default: '' },
  seatSection: { type: String, default: '' },
  seatRow: { type: String, default: '' },
  seatNumber: { type: String, default: '' },
  avatarUrl: { type: String, default: '' },
  role: { type: String, enum: ['user', 'staff', 'admin'], default: 'user' },
  preferences: {
    notifications: { type: Boolean, default: true },
    dietaryRestrictions: [String],
  },
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
