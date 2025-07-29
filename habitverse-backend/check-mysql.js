const mysql = require('mysql2/promise');
require('dotenv').config();

const checkMySQL = async () => {
  console.log('🔍 Checking MySQL connection...');
  
  try {
    // Try to connect to MySQL server
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || ''
    });

    console.log('✅ MySQL server is running');
    
    // Check if database exists
    const [databases] = await connection.execute('SHOW DATABASES');
    const dbExists = databases.some(db => db.Database === (process.env.DB_NAME || 'habitverse_db'));
    
    if (dbExists) {
      console.log('✅ Database exists');
    } else {
      console.log('⚠️  Database does not exist - will be created');
    }
    
    await connection.end();
    return true;
    
  } catch (error) {
    console.log('❌ MySQL connection failed:', error.message);
    console.log('\n📋 To fix this issue:');
    console.log('1. Install MySQL server (https://dev.mysql.com/downloads/mysql/)');
    console.log('2. Start MySQL service');
    console.log('3. Or install XAMPP/WAMP which includes MySQL');
    console.log('4. Make sure MySQL is running on port 3306');
    console.log('5. Update .env file with correct MySQL credentials');
    
    return false;
  }
};

checkMySQL().then(success => {
  process.exit(success ? 0 : 1);
});
