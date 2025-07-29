const axios = require('axios');

const BASE_URL = 'http://localhost:3002/api';
let authToken = '';
let userId = '';
let habitId = '';

// Test data
const testUser = {
  name: 'Test User',
  email: 'test@habitverse.com',
  password: 'password123'
};

const testHabit = {
  title: 'Morning Workout',
  description: 'Exercise for 30 minutes every morning',
  category: 'Fitness',
  icon: '💪',
  color: 16744448,
  is_public: false
};

// Helper function to make requests
const makeRequest = async (method, endpoint, data = null, useAuth = false) => {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {}
    };

    if (useAuth && authToken) {
      config.headers.Authorization = `Bearer ${authToken}`;
    }

    if (data) {
      config.data = data;
      config.headers['Content-Type'] = 'application/json';
    }

    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data || error.message,
      status: error.response?.status || 500
    };
  }
};

// Test functions
const testHealthCheck = async () => {
  console.log('\n🔍 Testing Health Check...');
  const result = await makeRequest('GET', '/health');
  
  if (result.success) {
    console.log('✅ Health check passed');
    console.log('   Response:', result.data.message);
  } else {
    console.log('❌ Health check failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testRegister = async () => {
  console.log('\n🔍 Testing User Registration...');
  const result = await makeRequest('POST', '/auth/register', testUser);
  
  if (result.success) {
    console.log('✅ Registration successful');
    authToken = result.data.data.token;
    userId = result.data.data.user.id;
    console.log('   User ID:', userId);
    console.log('   Token received:', authToken ? 'Yes' : 'No');
  } else {
    console.log('❌ Registration failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testLogin = async () => {
  console.log('\n🔍 Testing User Login...');
  const result = await makeRequest('POST', '/auth/login', {
    email: testUser.email,
    password: testUser.password
  });
  
  if (result.success) {
    console.log('✅ Login successful');
    authToken = result.data.data.token;
    console.log('   Token updated:', authToken ? 'Yes' : 'No');
  } else {
    console.log('❌ Login failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testGetProfile = async () => {
  console.log('\n🔍 Testing Get Profile...');
  const result = await makeRequest('GET', '/user/profile', null, true);
  
  if (result.success) {
    console.log('✅ Get profile successful');
    console.log('   User name:', result.data.data.user.name);
    console.log('   User email:', result.data.data.user.email);
    console.log('   User XP:', result.data.data.user.xp);
    console.log('   User level:', result.data.data.user.level);
  } else {
    console.log('❌ Get profile failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testCreateHabit = async () => {
  console.log('\n🔍 Testing Create Habit...');
  const result = await makeRequest('POST', '/habits', testHabit, true);
  
  if (result.success) {
    console.log('✅ Create habit successful');
    habitId = result.data.data.habit.id;
    console.log('   Habit ID:', habitId);
    console.log('   Habit title:', result.data.data.habit.title);
    console.log('   Habit category:', result.data.data.habit.category);
  } else {
    console.log('❌ Create habit failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testGetHabits = async () => {
  console.log('\n🔍 Testing Get Habits...');
  const result = await makeRequest('GET', '/habits', null, true);
  
  if (result.success) {
    console.log('✅ Get habits successful');
    console.log('   Number of habits:', result.data.data.habits.length);
    if (result.data.data.habits.length > 0) {
      console.log('   First habit:', result.data.data.habits[0].title);
    }
  } else {
    console.log('❌ Get habits failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testCheckHabit = async () => {
  console.log('\n🔍 Testing Check Habit...');
  const result = await makeRequest('POST', `/habits/check/${habitId}`, null, true);
  
  if (result.success) {
    console.log('✅ Check habit successful');
    console.log('   XP earned:', result.data.data.xp_earned);
    console.log('   Total XP:', result.data.data.total_xp);
    console.log('   Level:', result.data.data.level);
    console.log('   Streak:', result.data.data.streak);
    console.log('   Level up:', result.data.data.level_up ? 'Yes' : 'No');
  } else {
    console.log('❌ Check habit failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testGetHabitStats = async () => {
  console.log('\n🔍 Testing Get Habit Stats...');
  const result = await makeRequest('GET', `/habits/${habitId}/stats`, null, true);
  
  if (result.success) {
    console.log('✅ Get habit stats successful');
    const stats = result.data.data.stats;
    console.log('   Total checks:', stats.total_checks);
    console.log('   Current streak:', stats.current_streak);
    console.log('   Longest streak:', stats.longest_streak);
    console.log('   Total XP:', stats.total_xp);
    console.log('   Checked today:', stats.is_checked_today ? 'Yes' : 'No');
  } else {
    console.log('❌ Get habit stats failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testGetOverallStats = async () => {
  console.log('\n🔍 Testing Get Overall Stats...');
  const result = await makeRequest('GET', '/habits/stats', null, true);
  
  if (result.success) {
    console.log('✅ Get overall stats successful');
    const stats = result.data.data.stats;
    console.log('   Total habits:', stats.total_habits);
    console.log('   Total checks:', stats.total_checks);
    console.log('   Total XP:', stats.total_xp);
    console.log('   Completed today:', stats.completed_today);
    console.log('   Completion rate:', Math.round(stats.completion_rate * 100) + '%');
  } else {
    console.log('❌ Get overall stats failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testGetLeaderboard = async () => {
  console.log('\n🔍 Testing Get Leaderboard...');
  const result = await makeRequest('GET', '/leaderboard', null, true);
  
  if (result.success) {
    console.log('✅ Get leaderboard successful');
    console.log('   Number of users:', result.data.data.leaderboard.length);
    if (result.data.data.leaderboard.length > 0) {
      console.log('   Top user:', result.data.data.leaderboard[0].name);
      console.log('   Top user XP:', result.data.data.leaderboard[0].xp);
    }
  } else {
    console.log('❌ Get leaderboard failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

const testUpdateHabit = async () => {
  console.log('\n🔍 Testing Update Habit...');
  const result = await makeRequest('PUT', `/habits/${habitId}`, {
    title: 'Updated Morning Workout',
    description: 'Updated: Exercise for 45 minutes every morning'
  }, true);
  
  if (result.success) {
    console.log('✅ Update habit successful');
    console.log('   Updated title:', result.data.data.habit.title);
    console.log('   Updated description:', result.data.data.habit.description);
  } else {
    console.log('❌ Update habit failed');
    console.log('   Error:', result.error);
  }
  
  return result.success;
};

// Main test runner
const runAllTests = async () => {
  console.log('🧪 Starting HabitVerse API Tests...');
  console.log('=====================================');
  
  const tests = [
    { name: 'Health Check', fn: testHealthCheck },
    { name: 'User Registration', fn: testRegister },
    { name: 'User Login', fn: testLogin },
    { name: 'Get Profile', fn: testGetProfile },
    { name: 'Create Habit', fn: testCreateHabit },
    { name: 'Get Habits', fn: testGetHabits },
    { name: 'Check Habit', fn: testCheckHabit },
    { name: 'Get Habit Stats', fn: testGetHabitStats },
    { name: 'Get Overall Stats', fn: testGetOverallStats },
    { name: 'Update Habit', fn: testUpdateHabit },
    { name: 'Get Leaderboard', fn: testGetLeaderboard }
  ];
  
  let passed = 0;
  let failed = 0;
  
  for (const test of tests) {
    const result = await test.fn();
    if (result) {
      passed++;
    } else {
      failed++;
    }
    
    // Small delay between tests
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  console.log('\n=====================================');
  console.log('🧪 Test Results Summary:');
  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📊 Success Rate: ${Math.round((passed / (passed + failed)) * 100)}%`);
  
  if (failed === 0) {
    console.log('\n🎉 All tests passed! API is working perfectly!');
  } else {
    console.log('\n⚠️  Some tests failed. Please check the errors above.');
  }
};

// Check if server is running
const checkServer = async () => {
  console.log('🔍 Checking if server is running...');
  const result = await makeRequest('GET', '/health');
  
  if (result.success) {
    console.log('✅ Server is running, starting tests...');
    return true;
  } else {
    console.log('❌ Server is not running. Please start the server first with: npm start');
    return false;
  }
};

// Run tests
const main = async () => {
  const serverRunning = await checkServer();
  if (serverRunning) {
    await runAllTests();
  }
  process.exit(0);
};

main().catch(console.error);
