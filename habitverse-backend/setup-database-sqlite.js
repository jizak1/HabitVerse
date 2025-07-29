const { db } = require('./config/database-sqlite');
require('dotenv').config();

const setupDatabase = async () => {
  console.log('🚀 Setting up HabitVerse SQLite Database...');
  
  try {
    // Create tables
    console.log('📋 Creating tables...');

    // Users table
    await db.schema.dropTableIfExists('users');
    await db.schema.createTable('users', (table) => {
      table.string('id', 36).primary();
      table.string('name', 100).notNullable();
      table.string('email', 100).unique().notNullable();
      table.string('password', 255).notNullable();
      table.integer('xp').defaultTo(0);
      table.integer('level').defaultTo(1);
      table.string('avatar_url', 500).nullable();
      table.timestamps(true, true);
    });
    console.log('✅ Users table created');

    // Habits table
    await db.schema.dropTableIfExists('habits');
    await db.schema.createTable('habits', (table) => {
      table.string('id', 36).primary();
      table.string('user_id', 36).notNullable();
      table.string('title', 100).notNullable();
      table.text('description').nullable();
      table.string('category', 50).notNullable();
      table.string('icon', 10).notNullable();
      table.integer('color').notNullable();
      table.boolean('is_public').defaultTo(false);
      table.timestamps(true, true);
      
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    });
    console.log('✅ Habits table created');

    // Habit checks table
    await db.schema.dropTableIfExists('habit_checks');
    await db.schema.createTable('habit_checks', (table) => {
      table.string('id', 36).primary();
      table.string('habit_id', 36).notNullable();
      table.string('date_checked', 10).notNullable(); // YYYY-MM-DD format
      table.integer('xp_earned').defaultTo(10);
      table.timestamps(true, true);
      
      table.foreign('habit_id').references('id').inTable('habits').onDelete('CASCADE');
      table.unique(['habit_id', 'date_checked']);
    });
    console.log('✅ Habit checks table created');

    // Friends table
    await db.schema.dropTableIfExists('friends');
    await db.schema.createTable('friends', (table) => {
      table.string('id', 36).primary();
      table.string('user_id', 36).notNullable();
      table.string('friend_id', 36).notNullable();
      table.string('status', 20).defaultTo('pending'); // pending, accepted, blocked
      table.timestamps(true, true);
      
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.foreign('friend_id').references('id').inTable('users').onDelete('CASCADE');
      table.unique(['user_id', 'friend_id']);
    });
    console.log('✅ Friends table created');

    // Badges table
    await db.schema.dropTableIfExists('badges');
    await db.schema.createTable('badges', (table) => {
      table.string('id', 36).primary();
      table.string('user_id', 36).notNullable();
      table.string('badge_type', 50).notNullable();
      table.string('title', 100).notNullable();
      table.text('description').nullable();
      table.timestamps(true, true);
      
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    });
    console.log('✅ Badges table created');

    // Insert sample data
    console.log('📝 Inserting sample data...');
    
    // Sample user
    const userId = 'user-sample-123';
    await db('users').insert({
      id: userId,
      name: 'John Doe',
      email: 'john@example.com',
      password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
      xp: 150,
      level: 2
    });

    // Sample habits
    const habits = [
      {
        id: 'habit-1',
        user_id: userId,
        title: 'Morning Exercise',
        description: 'Do 30 minutes of exercise every morning',
        category: 'Fitness',
        icon: '💪',
        color: 16744448 // Orange
      },
      {
        id: 'habit-2',
        user_id: userId,
        title: 'Read Books',
        description: 'Read at least 20 pages of a book daily',
        category: 'Learning',
        icon: '📚',
        color: 2196243 // Blue
      },
      {
        id: 'habit-3',
        user_id: userId,
        title: 'Drink Water',
        description: 'Drink 8 glasses of water daily',
        category: 'Health',
        icon: '💧',
        color: 4285238 // Light Blue
      }
    ];

    await db('habits').insert(habits);

    // Sample habit checks
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    await db('habit_checks').insert([
      {
        id: 'check-1',
        habit_id: 'habit-1',
        date_checked: today,
        xp_earned: 10
      },
      {
        id: 'check-2',
        habit_id: 'habit-2',
        date_checked: yesterday,
        xp_earned: 10
      }
    ]);

    console.log('✅ Sample data inserted');
    console.log('🎉 Database setup completed successfully!');
    console.log('\n📊 Database Summary:');
    console.log('- Users: 1 sample user (john@example.com / password)');
    console.log('- Habits: 3 sample habits');
    console.log('- Habit Checks: 2 sample checks');
    console.log('\n🚀 You can now start the server with: npm start');

  } catch (error) {
    console.error('❌ Database setup failed:', error);
  } finally {
    await db.destroy();
    process.exit(0);
  }
};

setupDatabase();
