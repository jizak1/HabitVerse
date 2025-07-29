const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const db = new sqlite3.Database('./habitverse.db');

async function seedDatabase() {
  console.log('🌱 Seeding database with sample data...');

  try {
    // Create sample users
    const users = [
      {
        id: uuidv4(),
        name: 'Alice Johnson',
        email: 'alice@habitverse.com',
        password: await bcrypt.hash('password123', 10),
        avatar_url: null,
        xp: 250,
        level: 3,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: uuidv4(),
        name: 'Bob Smith',
        email: 'bob@habitverse.com',
        password: await bcrypt.hash('password123', 10),
        avatar_url: null,
        xp: 180,
        level: 2,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: uuidv4(),
        name: 'Carol Davis',
        email: 'carol@habitverse.com',
        password: await bcrypt.hash('password123', 10),
        avatar_url: null,
        xp: 320,
        level: 4,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    // Insert users
    for (const user of users) {
      await new Promise((resolve, reject) => {
        db.run(`
          INSERT OR REPLACE INTO users (id, name, email, password, avatar_url, xp, level, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [user.id, user.name, user.email, user.password, user.avatar_url, user.xp, user.level, user.created_at, user.updated_at], 
        function(err) {
          if (err) reject(err);
          else resolve();
        });
      });
    }

    // Create sample habits for each user
    const habitCategories = ['Health', 'Fitness', 'Learning', 'Productivity', 'Mindfulness'];
    const habitIcons = ['💪', '🏃', '📚', '💻', '🧘'];
    const habitColors = [0xFF4CAF50, 0xFFFF5722, 0xFF2196F3, 0xFFFF9800, 0xFF9C27B0];

    const sampleHabits = [
      { title: 'Morning Exercise', description: 'Do 30 minutes of exercise every morning', category: 'Fitness', icon: '💪', color: 0xFFFF5722 },
      { title: 'Read Daily', description: 'Read for at least 20 minutes every day', category: 'Learning', icon: '📚', color: 0xFF2196F3 },
      { title: 'Drink Water', description: 'Drink 8 glasses of water daily', category: 'Health', icon: '💧', color: 0xFF4CAF50 },
      { title: 'Meditation', description: 'Meditate for 10 minutes daily', category: 'Mindfulness', icon: '🧘', color: 0xFF9C27B0 },
      { title: 'Code Practice', description: 'Practice coding for 1 hour daily', category: 'Productivity', icon: '💻', color: 0xFFFF9800 }
    ];

    for (let i = 0; i < users.length; i++) {
      const user = users[i];
      
      // Create 2-3 habits per user
      const numHabits = Math.floor(Math.random() * 2) + 2; // 2-3 habits
      
      for (let j = 0; j < numHabits; j++) {
        const habit = sampleHabits[j % sampleHabits.length];
        const habitId = uuidv4();
        
        await new Promise((resolve, reject) => {
          db.run(`
            INSERT INTO habits (id, user_id, title, description, category, icon, color, is_public, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `, [
            habitId, 
            user.id, 
            habit.title, 
            habit.description, 
            habit.category, 
            habit.icon, 
            habit.color, 
            Math.random() > 0.5 ? 1 : 0, // Random public/private
            new Date().toISOString(), 
            new Date().toISOString()
          ], function(err) {
            if (err) reject(err);
            else resolve();
          });
        });

        // Create some habit checks for the past few days
        const daysBack = Math.floor(Math.random() * 7) + 1; // 1-7 days
        
        for (let k = 0; k < daysBack; k++) {
          const checkDate = new Date();
          checkDate.setDate(checkDate.getDate() - k);
          
          // 70% chance of completing the habit each day
          if (Math.random() > 0.3) {
            const dateStr = checkDate.toISOString().split('T')[0]; // YYYY-MM-DD format
            await new Promise((resolve, reject) => {
              db.run(`
                INSERT INTO habit_checks (id, habit_id, date_checked, xp_earned, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
              `, [
                uuidv4(),
                habitId,
                dateStr,
                10, // Standard XP per habit
                checkDate.toISOString(),
                checkDate.toISOString()
              ], function(err) {
                if (err) reject(err);
                else resolve();
              });
            });
          }
        }
      }
    }

    // Create some friendships
    const friendships = [
      [users[0].id, users[1].id], // Alice and Bob are friends
      [users[1].id, users[2].id], // Bob and Carol are friends
      [users[0].id, users[2].id]  // Alice and Carol are friends
    ];

    for (const [userId, friendId] of friendships) {
      await new Promise((resolve, reject) => {
        db.run(`
          INSERT OR REPLACE INTO friends (id, user_id, friend_id, status, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?)
        `, [uuidv4(), userId, friendId, 'accepted', new Date().toISOString(), new Date().toISOString()],
        function(err) {
          if (err) reject(err);
          else resolve();
        });
      });

      // Create reverse friendship
      await new Promise((resolve, reject) => {
        db.run(`
          INSERT OR REPLACE INTO friends (id, user_id, friend_id, status, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?)
        `, [uuidv4(), friendId, userId, 'accepted', new Date().toISOString(), new Date().toISOString()],
        function(err) {
          if (err) reject(err);
          else resolve();
        });
      });
    }

    console.log('✅ Database seeded successfully!');
    console.log(`👥 Created ${users.length} users`);
    console.log(`🎯 Created sample habits and habit checks`);
    console.log(`🤝 Created ${friendships.length} friendships`);
    console.log('\n📧 Sample user credentials:');
    users.forEach(user => {
      console.log(`   ${user.name}: ${user.email} / password123`);
    });

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    db.close();
  }
}

// Run the seeding
seedDatabase();
