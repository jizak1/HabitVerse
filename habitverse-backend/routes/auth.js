const Joi = require('@hapi/joi');
const Boom = require('@hapi/boom');
const { db } = require('../config/database-sqlite');
const { generateToken, hashPassword, comparePassword } = require('../utils/auth');
const { generateId, isValidEmail, sanitizeUser, successResponse } = require('../utils/helpers');

const authRoutes = [
  // Register
  {
    method: 'POST',
    path: '/api/auth/register',
    options: {
      validate: {
        payload: Joi.object({
          name: Joi.string().min(2).max(100).required(),
          email: Joi.string().email().required(),
          password: Joi.string().min(6).required()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const { name, email, password } = request.payload;

        // Check if email already exists
        const existingUser = await db('users').where('email', email).first();
        if (existingUser) {
          return Boom.badRequest('Email already registered');
        }

        // Hash password
        const hashedPassword = await hashPassword(password);

        // Create user
        const userId = generateId();
        const userData = {
          id: userId,
          name,
          email,
          password: hashedPassword,
          xp: 0,
          level: 1
        };

        await db('users').insert(userData);

        // Generate token
        const token = generateToken({ 
          id: userId, 
          email, 
          name 
        });

        // Get user without password
        const user = await db('users').where('id', userId).first();
        const sanitizedUser = sanitizeUser(user);

        return h.response(successResponse({
          token,
          user: sanitizedUser
        }, 'Registration successful')).code(201);

      } catch (error) {
        console.error('Register error:', error);
        return Boom.internal('Registration failed');
      }
    }
  },

  // Login
  {
    method: 'POST',
    path: '/api/auth/login',
    options: {
      validate: {
        payload: Joi.object({
          email: Joi.string().email().required(),
          password: Joi.string().required()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const { email, password } = request.payload;

        // Find user
        const user = await db('users').where('email', email).first();
        if (!user) {
          return Boom.unauthorized('Invalid email or password');
        }

        // Check password
        const isValidPassword = await comparePassword(password, user.password);
        if (!isValidPassword) {
          return Boom.unauthorized('Invalid email or password');
        }

        // Generate token
        const token = generateToken({ 
          id: user.id, 
          email: user.email, 
          name: user.name 
        });

        // Return user without password
        const sanitizedUser = sanitizeUser(user);

        return successResponse({
          token,
          user: sanitizedUser
        }, 'Login successful');

      } catch (error) {
        console.error('Login error:', error);
        return Boom.internal('Login failed');
      }
    }
  },

  // Get current user profile
  {
    method: 'GET',
    path: '/api/user/profile',
    options: {
      pre: [
        { method: require('../utils/auth').authMiddleware }
      ]
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;

        const user = await db('users').where('id', userId).first();
        if (!user) {
          return Boom.notFound('User not found');
        }

        const sanitizedUser = sanitizeUser(user);
        return successResponse({ user: sanitizedUser });

      } catch (error) {
        console.error('Profile error:', error);
        return Boom.internal('Failed to get profile');
      }
    }
  },

  // Update user profile
  {
    method: 'PUT',
    path: '/api/user/profile',
    options: {
      pre: [
        { method: require('../utils/auth').authMiddleware }
      ],
      validate: {
        payload: Joi.object({
          name: Joi.string().min(2).max(100).optional(),
          avatar_url: Joi.string().uri().optional().allow('')
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const updateData = request.payload;

        // Update user
        await db('users').where('id', userId).update({
          ...updateData,
          updated_at: new Date()
        });

        // Get updated user
        const user = await db('users').where('id', userId).first();
        const sanitizedUser = sanitizeUser(user);

        return successResponse({ user: sanitizedUser }, 'Profile updated successfully');

      } catch (error) {
        console.error('Update profile error:', error);
        return Boom.internal('Failed to update profile');
      }
    }
  }
];

module.exports = authRoutes;
