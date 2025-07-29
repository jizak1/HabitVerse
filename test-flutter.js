const { spawn } = require('child_process');
const path = require('path');

console.log('🧪 Testing Flutter App Compilation...');

const flutterDir = path.join(__dirname, 'habitverse');

// Test Flutter compilation
const testFlutter = () => {
  return new Promise((resolve, reject) => {
    console.log('🔨 Running flutter analyze...');
    
    const flutter = spawn('flutter', ['analyze'], {
      cwd: flutterDir,
      stdio: 'pipe'
    });

    let output = '';
    let errorOutput = '';

    flutter.stdout.on('data', (data) => {
      output += data.toString();
    });

    flutter.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });

    flutter.on('close', (code) => {
      if (code === 0) {
        console.log('✅ Flutter analyze completed successfully!');
        console.log('Output:', output);
        resolve({ success: true, output, code });
      } else {
        console.error('❌ Flutter analyze failed!');
        console.error('Error output:', errorOutput);
        console.error('Output:', output);
        resolve({ success: false, output, errorOutput, code });
      }
    });

    flutter.on('error', (err) => {
      console.error('❌ Failed to run flutter analyze:', err.message);
      reject(err);
    });

    // Timeout after 60 seconds
    setTimeout(() => {
      flutter.kill('SIGTERM');
      reject(new Error('Flutter analyze timeout'));
    }, 60000);
  });
};

// Run the test
testFlutter()
  .then((result) => {
    if (result.success) {
      console.log('\n✅ Flutter app compilation test passed!');
      process.exit(0);
    } else {
      console.log('\n❌ Flutter app compilation test failed!');
      process.exit(1);
    }
  })
  .catch((error) => {
    console.error('\n❌ Test failed with error:', error.message);
    process.exit(1);
  });

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Terminating test...');
  process.exit(0);
});
