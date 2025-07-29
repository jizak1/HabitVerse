const knex = require('knex');
const path = require('path');
require('dotenv').config();

const db = knex({
  client: 'sqlite3',
  connection: {
    filename: path.join(__dirname, '..', 'habitverse.db')
  },
  useNullAsDefault: true,
  pool: {
    min: 2,
    max: 10
  },
  migrations: {
    tableName: 'knex_migrations'
  }
});

// Test database connection
const testConnection = async () => {
  try {
    await db.raw('SELECT 1');
    console.log('✅ SQLite database connected successfully');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
};

module.exports = { db, testConnection };
