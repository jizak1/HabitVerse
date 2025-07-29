const Joi = require('@hapi/joi');
const Boom = require('@hapi/boom');
const { db } = require('../config/database-sqlite');
const { authMiddleware } = require('../utils/auth');
const { generateId, sanitizeUser, successResponse } = require('../utils/helpers');

const socialRoutes = [
  // Get leaderboard
  {
    method: 'GET',
    path: '/api/leaderboard',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        query: Joi.object({
          period: Joi.string().valid('weekly', 'monthly', 'all').default('weekly'),
          limit: Joi.number().integer().min(1).max(100).default(10)
        })
      }
    },
    handler: async (request, h) => {
      try {
        const { period, limit } = request.query;
        
        let dateFilter = '';
        if (period === 'weekly') {
          const weekAgo = new Date();
          weekAgo.setDate(weekAgo.getDate() - 7);
          dateFilter = weekAgo.toISOString().split('T')[0];
        } else if (period === 'monthly') {
          const monthAgo = new Date();
          monthAgo.setMonth(monthAgo.getMonth() - 1);
          dateFilter = monthAgo.toISOString().split('T')[0];
        }

        let query = db('users')
          .select('id', 'name', 'email', 'xp', 'level', 'avatar_url')
          .orderBy('xp', 'desc')
          .limit(limit);

        // For weekly/monthly, we could filter by XP gained in that period
        // For now, we'll use total XP but this could be enhanced
        
        const users = await query;
        
        const leaderboard = users.map((user, index) => ({
          rank: index + 1,
          ...sanitizeUser(user)
        }));

        return successResponse({ 
          leaderboard,
          period,
          total_users: users.length 
        });

      } catch (error) {
        console.error('Get leaderboard error:', error);
        return Boom.internal('Failed to get leaderboard');
      }
    }
  },

  // Add friend
  {
    method: 'POST',
    path: '/api/friends/add',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        payload: Joi.object({
          friend_email: Joi.string().email().required()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const { friend_email } = request.payload;

        // Check if trying to add self
        if (friend_email === request.auth.user.email) {
          return Boom.badRequest('Cannot add yourself as friend');
        }

        // Find friend by email
        const friend = await db('users').where('email', friend_email).first();
        if (!friend) {
          return Boom.notFound('User not found');
        }

        // Check if friendship already exists
        const existingFriendship = await db('friends')
          .where(function() {
            this.where('user_id', userId).where('friend_id', friend.id);
          })
          .orWhere(function() {
            this.where('user_id', friend.id).where('friend_id', userId);
          })
          .first();

        if (existingFriendship) {
          return Boom.badRequest('Friendship already exists');
        }

        // Create friendship
        const friendshipData = {
          id: generateId(),
          user_id: userId,
          friend_id: friend.id,
          status: 'accepted' // For simplicity, auto-accept
        };

        await db('friends').insert(friendshipData);

        return h.response(successResponse(
          { friend: sanitizeUser(friend) }, 
          'Friend added successfully'
        )).code(201);

      } catch (error) {
        console.error('Add friend error:', error);
        return Boom.internal('Failed to add friend');
      }
    }
  },

  // Get friends list
  {
    method: 'GET',
    path: '/api/friends',
    options: {
      pre: [{ method: authMiddleware }]
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;

        const friends = await db('friends')
          .join('users', function() {
            this.on('users.id', '=', db.raw('CASE WHEN friends.user_id = ? THEN friends.friend_id ELSE friends.user_id END', [userId]));
          })
          .where(function() {
            this.where('friends.user_id', userId).orWhere('friends.friend_id', userId);
          })
          .where('friends.status', 'accepted')
          .select('users.id', 'users.name', 'users.email', 'users.xp', 'users.level', 'users.avatar_url');

        const sanitizedFriends = friends.map(friend => sanitizeUser(friend));

        return successResponse({ friends: sanitizedFriends });

      } catch (error) {
        console.error('Get friends error:', error);
        return Boom.internal('Failed to get friends');
      }
    }
  },

  // Get friend's public habits
  {
    method: 'GET',
    path: '/api/friends/{id}/habits',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        params: Joi.object({
          id: Joi.string().required()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const friendId = request.params.id;

        // Check if they are friends
        const friendship = await db('friends')
          .where(function() {
            this.where('user_id', userId).where('friend_id', friendId);
          })
          .orWhere(function() {
            this.where('user_id', friendId).where('friend_id', userId);
          })
          .where('status', 'accepted')
          .first();

        if (!friendship) {
          return Boom.forbidden('Not friends with this user');
        }

        // Get friend's public habits
        const habits = await db('habits')
          .where('user_id', friendId)
          .where('is_public', true)
          .orderBy('created_at', 'desc');

        return successResponse({ habits });

      } catch (error) {
        console.error('Get friend habits error:', error);
        return Boom.internal('Failed to get friend habits');
      }
    }
  },

  // Remove friend
  {
    method: 'DELETE',
    path: '/api/friends/{id}',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        params: Joi.object({
          id: Joi.string().required()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const friendId = request.params.id;

        // Delete friendship
        const deleted = await db('friends')
          .where(function() {
            this.where('user_id', userId).where('friend_id', friendId);
          })
          .orWhere(function() {
            this.where('user_id', friendId).where('friend_id', userId);
          })
          .del();

        if (deleted === 0) {
          return Boom.notFound('Friendship not found');
        }

        return successResponse(null, 'Friend removed successfully');

      } catch (error) {
        console.error('Remove friend error:', error);
        return Boom.internal('Failed to remove friend');
      }
    }
  },

  // Search users
  {
    method: 'GET',
    path: '/api/users/search',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        query: Joi.object({
          q: Joi.string().min(2).required(),
          limit: Joi.number().integer().min(1).max(20).default(10)
        })
      }
    },
    handler: async (request, h) => {
      try {
        const { q, limit } = request.query;
        const userId = request.auth.user.id;

        const users = await db('users')
          .where('name', 'like', `%${q}%`)
          .orWhere('email', 'like', `%${q}%`)
          .whereNot('id', userId) // Exclude current user
          .limit(limit)
          .select('id', 'name', 'email', 'xp', 'level', 'avatar_url');

        const sanitizedUsers = users.map(user => sanitizeUser(user));

        return successResponse({ users: sanitizedUsers });

      } catch (error) {
        console.error('Search users error:', error);
        return Boom.internal('Failed to search users');
      }
    }
  }
];

module.exports = socialRoutes;
