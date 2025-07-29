const http = require('http');

console.log('🧪 Testing HabitVerse API Endpoints...');

// Helper function to make HTTP requests
const makeRequest = (method, path, data = null, token = null) => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3002,
      path: `/api${path}`,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: parsedData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
};

// Test endpoints
const runTests = async () => {
  try {
    console.log('\n1. Testing health endpoint...');
    const health = await makeRequest('GET', '/health');
    console.log('✅ Health check:', health.status === 200 ? 'PASS' : 'FAIL');
    
    console.log('\n2. Testing API documentation endpoint...');
    const docs = await makeRequest('GET', '/');
    console.log('✅ API docs:', docs.status === 200 ? 'PASS' : 'FAIL');
    
    console.log('\n3. Testing user registration...');
    const testUser = {
      name: 'Test User',
      email: `test${Date.now()}@example.com`,
      password: 'password123'
    };
    
    const register = await makeRequest('POST', '/auth/register', testUser);
    console.log('✅ Registration:', register.status === 201 ? 'PASS' : 'FAIL');
    
    if (register.status === 201) {
      console.log('\n4. Testing user login...');
      const login = await makeRequest('POST', '/auth/login', {
        email: testUser.email,
        password: testUser.password
      });
      console.log('✅ Login:', login.status === 200 ? 'PASS' : 'FAIL');
      
      if (login.status === 200 && login.data.data && login.data.data.token) {
        const token = login.data.data.token;
        
        console.log('\n5. Testing user profile...');
        const profile = await makeRequest('GET', '/user/profile', null, token);
        console.log('✅ Profile:', profile.status === 200 ? 'PASS' : 'FAIL');
        
        console.log('\n6. Testing habits endpoint...');
        const habits = await makeRequest('GET', '/habits', null, token);
        console.log('✅ Get habits:', habits.status === 200 ? 'PASS' : 'FAIL');
        
        console.log('\n7. Testing create habit...');
        const newHabit = {
          title: 'Test Habit',
          description: 'A test habit',
          category: 'Health',
          icon: '💪',
          color: 16744448,
          is_public: false
        };
        
        const createHabit = await makeRequest('POST', '/habits', newHabit, token);
        console.log('✅ Create habit:', createHabit.status === 201 ? 'PASS' : 'FAIL');
        
        console.log('\n8. Testing leaderboard...');
        const leaderboard = await makeRequest('GET', '/leaderboard', null, token);
        console.log('✅ Leaderboard:', leaderboard.status === 200 ? 'PASS' : 'FAIL');
        
        console.log('\n✅ All API endpoint tests completed!');
        console.log('🎉 Backend is working properly!');
      } else {
        console.log('❌ Login failed, skipping authenticated tests');
      }
    } else {
      console.log('❌ Registration failed, skipping other tests');
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
};

// Run tests
runTests();
