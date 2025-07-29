const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'habitverse_secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// Generate JWT token
const generateToken = (payload) => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
};

// Verify JWT token
const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
};

// Hash password
const hashPassword = async (password) => {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

// Compare password
const comparePassword = async (password, hashedPassword) => {
  return await bcrypt.compare(password, hashedPassword);
};

// Extract token from request
const extractToken = (request) => {
  const authorization = request.headers.authorization;
  if (!authorization) {
    throw new Error('No authorization header');
  }
  
  const token = authorization.replace('Bearer ', '');
  if (!token) {
    throw new Error('No token provided');
  }
  
  return token;
};

// Auth middleware for Hapi
const authMiddleware = async (request, h) => {
  try {
    const token = extractToken(request);
    const decoded = verifyToken(token);
    request.auth = { user: decoded };
    return h.continue;
  } catch (error) {
    const Boom = require('@hapi/boom');
    return Boom.unauthorized('Invalid token');
  }
};

module.exports = {
  generateToken,
  verifyToken,
  hashPassword,
  comparePassword,
  extractToken,
  authMiddleware
};
