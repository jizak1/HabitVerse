const Joi = require('@hapi/joi');
const Boom = require('@hapi/boom');
const { db } = require('../config/database-sqlite');
const { authMiddleware } = require('../utils/auth');
const { 
  generateId, 
  getCurrentDate, 
  calculateStreak, 
  calculateLevel,
  successResponse 
} = require('../utils/helpers');

const habitRoutes = [
  // Get all habits for user
  {
    method: 'GET',
    path: '/api/habits',
    options: {
      pre: [{ method: authMiddleware }]
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;

        const habits = await db('habits')
          .where('user_id', userId)
          .orderBy('created_at', 'desc');

        return successResponse({ habits });

      } catch (error) {
        console.error('Get habits error:', error);
        return Boom.internal('Failed to get habits');
      }
    }
  },

  // Create new habit
  {
    method: 'POST',
    path: '/api/habits',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        payload: Joi.object({
          title: Joi.string().min(1).max(100).required(),
          description: Joi.string().max(500).optional().allow(''),
          category: Joi.string().valid(
            'Health', 'Fitness', 'Learning', 'Productivity', 
            'Mindfulness', 'Social', 'Creative', 'Finance'
          ).required(),
          icon: Joi.string().max(10).required(),
          color: Joi.number().integer().required(),
          is_public: Joi.boolean().optional().default(false)
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const habitData = {
          id: generateId(),
          user_id: userId,
          ...request.payload
        };

        await db('habits').insert(habitData);

        const habit = await db('habits').where('id', habitData.id).first();
        return h.response(successResponse({ habit }, 'Habit created successfully')).code(201);

      } catch (error) {
        console.error('Create habit error:', error);
        return Boom.internal('Failed to create habit');
      }
    }
  },

  // Update habit
  {
    method: 'PUT',
    path: '/api/habits/{id}',
    options: {
      pre: [{ method: authMiddleware }],
      validate: {
        params: Joi.object({
          id: Joi.string().required()
        }),
        payload: Joi.object({
          title: Joi.string().min(1).max(100).optional(),
          description: Joi.string().max(500).optional().allow(''),
          category: Joi.string().valid(
            'Health', 'Fitness', 'Learning', 'Productivity', 
            'Mindfulness', 'Social', 'Creative', 'Finance'
          ).optional(),
          icon: Joi.string().max(10).optional(),
          color: Joi.number().integer().optional(),
          is_public: Joi.boolean().optional()
        })
      }
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;
        const habitId = request.params.id;

        // Check if habit exists and belongs to user
        const existingHabit = await db('habits')
          .where('id', habitId)
          .where('user_id', userId)
          .first();

        if (!existingHabit) {
          return Boom.notFound('Habit not found');
        }

        // Update habit
        await db('habits')
          .where('id', habitId)
          .update({
            ...request.payload,
            updated_at: new Date()
          });

        const habit = await db('habits').where('id', habitId).first();
        return successResponse({ habit }, 'Habit updated successfully');

      } catch (error) {
        console.error('Update habit error:', error);
        return Boom.internal('Failed to update habit');
      }
    }
  },

  // Delete habit
  {
    method: 'DELETE',
    path: '/api/habits/{id}',
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
        const habitId = request.params.id;

        // Check if habit exists and belongs to user
        const existingHabit = await db('habits')
          .where('id', habitId)
          .where('user_id', userId)
          .first();

        if (!existingHabit) {
          return Boom.notFound('Habit not found');
        }

        // Delete habit (will cascade delete checks)
        await db('habits').where('id', habitId).del();

        return successResponse(null, 'Habit deleted successfully');

      } catch (error) {
        console.error('Delete habit error:', error);
        return Boom.internal('Failed to delete habit');
      }
    }
  },

  // Check habit (mark as completed for today)
  {
    method: 'POST',
    path: '/api/habits/check/{id}',
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
        const habitId = request.params.id;
        const today = getCurrentDate();

        // Check if habit exists and belongs to user
        const habit = await db('habits')
          .where('id', habitId)
          .where('user_id', userId)
          .first();

        if (!habit) {
          return Boom.notFound('Habit not found');
        }

        // Check if already checked today
        const existingCheck = await db('habit_checks')
          .where('habit_id', habitId)
          .where('date_checked', today)
          .first();

        if (existingCheck) {
          return Boom.badRequest('Habit already checked today');
        }

        // Create habit check
        const xpEarned = 10; // Base XP
        const checkData = {
          id: generateId(),
          habit_id: habitId,
          date_checked: today,
          xp_earned: xpEarned
        };

        await db('habit_checks').insert(checkData);

        // Update user XP
        const user = await db('users').where('id', userId).first();
        const newXP = user.xp + xpEarned;
        const newLevel = calculateLevel(newXP);
        const levelUp = newLevel > user.level;

        await db('users').where('id', userId).update({
          xp: newXP,
          level: newLevel,
          updated_at: new Date()
        });

        // Calculate streak
        const allChecks = await db('habit_checks')
          .where('habit_id', habitId)
          .orderBy('date_checked', 'desc');

        const streak = calculateStreak(allChecks);

        return successResponse({
          xp_earned: xpEarned,
          total_xp: newXP,
          level: newLevel,
          level_up: levelUp,
          streak
        }, 'Habit checked successfully');

      } catch (error) {
        console.error('Check habit error:', error);
        return Boom.internal('Failed to check habit');
      }
    }
  },

  // Get habit statistics
  {
    method: 'GET',
    path: '/api/habits/{id}/stats',
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
        const habitId = request.params.id;

        // Check if habit exists and belongs to user
        const habit = await db('habits')
          .where('id', habitId)
          .where('user_id', userId)
          .first();

        if (!habit) {
          return Boom.notFound('Habit not found');
        }

        // Get all checks for this habit
        const checks = await db('habit_checks')
          .where('habit_id', habitId)
          .orderBy('date_checked', 'desc');

        // Calculate statistics
        const totalChecks = checks.length;
        const currentStreak = calculateStreak(checks);
        
        // Calculate longest streak
        let longestStreak = 0;
        let tempStreak = 0;
        let lastDate = null;

        for (const check of checks.reverse()) {
          const checkDate = new Date(check.date_checked);
          
          if (!lastDate || (checkDate - lastDate) === 86400000) { // 1 day difference
            tempStreak++;
            longestStreak = Math.max(longestStreak, tempStreak);
          } else {
            tempStreak = 1;
          }
          
          lastDate = checkDate;
        }

        const totalXp = checks.reduce((sum, check) => sum + check.xp_earned, 0);
        const lastChecked = checks.length > 0 ? checks[0].date_checked : null;
        const checkDates = checks.map(check => check.date_checked);

        // Check if checked today
        const today = getCurrentDate();
        const isCheckedToday = checks.some(check => check.date_checked === today);

        const stats = {
          habit_id: habitId,
          total_checks: totalChecks,
          current_streak: currentStreak,
          longest_streak: longestStreak,
          total_xp: totalXp,
          last_checked: lastChecked,
          check_dates: checkDates,
          is_checked_today: isCheckedToday
        };

        return successResponse({ stats });

      } catch (error) {
        console.error('Get habit stats error:', error);
        return Boom.internal('Failed to get habit statistics');
      }
    }
  },

  // Get overall statistics
  {
    method: 'GET',
    path: '/api/habits/stats',
    options: {
      pre: [{ method: authMiddleware }]
    },
    handler: async (request, h) => {
      try {
        const userId = request.auth.user.id;

        // Get all user habits
        const habits = await db('habits').where('user_id', userId);
        
        // Get all checks for user habits
        const habitIds = habits.map(h => h.id);
        const allChecks = await db('habit_checks')
          .whereIn('habit_id', habitIds)
          .orderBy('date_checked', 'desc');

        // Calculate overall stats
        const totalHabits = habits.length;
        const totalChecks = allChecks.length;
        const totalXp = allChecks.reduce((sum, check) => sum + check.xp_earned, 0);

        // Today's stats
        const today = getCurrentDate();
        const todayChecks = allChecks.filter(check => check.date_checked === today);
        const completedToday = todayChecks.length;

        // Weekly stats
        const weekStart = new Date();
        weekStart.setDate(weekStart.getDate() - 7);
        const weekStartStr = weekStart.toISOString().split('T')[0];
        
        const weeklyChecks = allChecks.filter(check => check.date_checked >= weekStartStr);
        const weeklyTotal = weeklyChecks.length;

        const stats = {
          total_habits: totalHabits,
          total_checks: totalChecks,
          total_xp: totalXp,
          completed_today: completedToday,
          weekly_total: weeklyTotal,
          completion_rate: totalHabits > 0 ? completedToday / totalHabits : 0
        };

        return successResponse({ stats });

      } catch (error) {
        console.error('Get overall stats error:', error);
        return Boom.internal('Failed to get statistics');
      }
    }
  }
];

module.exports = habitRoutes;
