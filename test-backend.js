const http = require('http');

console.log('🧪 Testing HabitVerse Backend...');

// Test if server is running
const testServer = () => {
  return new Promise((resolve, reject) => {
    const req = http.get('http://localhost:3002/api/health', (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          resolve({ status: res.statusCode, data: response });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
};

// Start backend server
const { spawn } = require('child_process');

console.log('🚀 Starting backend server...');
const server = spawn('node', ['server.js'], {
  cwd: './habitverse-backend',
  stdio: 'pipe'
});

let serverOutput = '';
server.stdout.on('data', (data) => {
  serverOutput += data.toString();
  console.log('Server:', data.toString().trim());
});

server.stderr.on('data', (data) => {
  console.error('Server Error:', data.toString().trim());
});

// Wait for server to start, then test
setTimeout(async () => {
  try {
    console.log('\n🧪 Testing server health...');
    const result = await testServer();
    console.log('✅ Server is running!');
    console.log('Status:', result.status);
    console.log('Response:', JSON.stringify(result.data, null, 2));
    
    // Kill server
    server.kill('SIGTERM');
    console.log('\n✅ Backend test completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Server test failed:', error.message);
    server.kill('SIGTERM');
    process.exit(1);
  }
}, 3000);

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Terminating test...');
  server.kill('SIGTERM');
  process.exit(0);
});
