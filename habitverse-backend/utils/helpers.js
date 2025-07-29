const { v4: uuidv4 } = require('uuid');

// Generate UUID
const generateId = () => {
  return uuidv4();
};

// Calculate level from XP
const calculateLevel = (xp) => {
  return Math.floor(xp / 100) + 1;
};

// Calculate XP needed for next level
const getXPForLevel = (level) => {
  return level * 100;
};

// Get current date in YYYY-MM-DD format
const getCurrentDate = () => {
  return new Date().toISOString().split('T')[0];
};

// Get date range for week
const getWeekRange = (date = new Date()) => {
  const start = new Date(date);
  start.setDate(date.getDate() - date.getDay() + 1); // Monday
  
  const end = new Date(start);
  end.setDate(start.getDate() + 6); // Sunday
  
  return {
    start: start.toISOString().split('T')[0],
    end: end.toISOString().split('T')[0]
  };
};

// Get date range for month
const getMonthRange = (date = new Date()) => {
  const start = new Date(date.getFullYear(), date.getMonth(), 1);
  const end = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  
  return {
    start: start.toISOString().split('T')[0],
    end: end.toISOString().split('T')[0]
  };
};

// Calculate streak from habit checks
const calculateStreak = (checks) => {
  if (!checks || checks.length === 0) return 0;
  
  // Sort checks by date (newest first)
  const sortedChecks = checks.sort((a, b) => new Date(b.date_checked) - new Date(a.date_checked));
  
  let streak = 0;
  let currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);
  
  for (const check of sortedChecks) {
    const checkDate = new Date(check.date_checked);
    checkDate.setHours(0, 0, 0, 0);
    
    const diffDays = Math.floor((currentDate - checkDate) / (1000 * 60 * 60 * 24));
    
    if (diffDays === streak) {
      streak++;
      currentDate.setDate(currentDate.getDate() - 1);
    } else {
      break;
    }
  }
  
  return streak;
};

// Calculate completion rate
const calculateCompletionRate = (totalChecks, daysSinceCreation) => {
  if (daysSinceCreation === 0) return 0;
  return Math.min(totalChecks / daysSinceCreation, 1);
};

// Validate email format
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Sanitize user data (remove password)
const sanitizeUser = (user) => {
  const { password, ...sanitizedUser } = user;
  return sanitizedUser;
};

// Format response
const formatResponse = (success, data = null, message = null, meta = null) => {
  const response = { success };
  
  if (data !== null) response.data = data;
  if (message !== null) response.message = message;
  if (meta !== null) response.meta = meta;
  
  return response;
};

// Error response
const errorResponse = (message, statusCode = 400) => {
  return {
    success: false,
    error: {
      message,
      statusCode
    }
  };
};

// Success response
const successResponse = (data, message = 'Success') => {
  return {
    success: true,
    message,
    data
  };
};

module.exports = {
  generateId,
  calculateLevel,
  getXPForLevel,
  getCurrentDate,
  getWeekRange,
  getMonthRange,
  calculateStreak,
  calculateCompletionRate,
  isValidEmail,
  sanitizeUser,
  formatResponse,
  errorResponse,
  successResponse
};
