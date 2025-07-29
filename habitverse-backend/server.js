const Hapi = require('@hapi/hapi');
const Inert = require('@hapi/inert');
const Vision = require('@hapi/vision');
require('dotenv').config();

const { testConnection } = require('./config/database-sqlite');
const authRoutes = require('./routes/auth');
const habitRoutes = require('./routes/habits');
const socialRoutes = require('./routes/social');

const init = async () => {
  // Test database connection first
  const dbConnected = await testConnection();
  if (!dbConnected) {
    console.error('❌ Cannot start server without database connection');
    process.exit(1);
  }

  // Create server
  const server = Hapi.server({
    port: 3002,
    host: 'localhost',
    routes: {
      cors: {
        origin: ['*'], // Allow all origins for development
        headers: ['Accept', 'Authorization', 'Content-Type', 'If-None-Match'],
        additionalHeaders: ['cache-control', 'x-requested-with']
      }
    }
  });

  // Register plugins
  await server.register([
    Inert,
    Vision
  ]);

  // Add routes
  server.route([
    // Health check
    {
      method: 'GET',
      path: '/api/health',
      handler: (request, h) => {
        return {
          success: true,
          message: 'HabitVerse API is running!',
          timestamp: new Date().toISOString(),
          version: '1.0.0'
        };
      }
    },

    // API documentation
    {
      method: 'GET',
      path: '/api',
      handler: (request, h) => {
        return {
          success: true,
          message: 'Welcome to HabitVerse API',
          version: '1.0.0',
          endpoints: {
            auth: {
              'POST /api/auth/register': 'Register new user',
              'POST /api/auth/login': 'Login user',
              'GET /api/user/profile': 'Get user profile',
              'PUT /api/user/profile': 'Update user profile'
            },
            habits: {
              'GET /api/habits': 'Get user habits',
              'POST /api/habits': 'Create new habit',
              'PUT /api/habits/{id}': 'Update habit',
              'DELETE /api/habits/{id}': 'Delete habit',
              'POST /api/habits/check/{id}': 'Check habit for today',
              'GET /api/habits/{id}/stats': 'Get habit statistics',
              'GET /api/habits/stats': 'Get overall statistics'
            },
            social: {
              'GET /api/leaderboard': 'Get leaderboard',
              'POST /api/friends/add': 'Add friend',
              'GET /api/friends': 'Get friends list',
              'GET /api/friends/{id}/habits': 'Get friend public habits',
              'DELETE /api/friends/{id}': 'Remove friend',
              'GET /api/users/search': 'Search users'
            }
          }
        };
      }
    },

    // Add all route modules
    ...authRoutes,
    ...habitRoutes,
    ...socialRoutes
  ]);

  // Error handling
  server.ext('onPreResponse', (request, h) => {
    const response = request.response;
    
    if (response.isBoom) {
      const error = response;
      const statusCode = error.output.statusCode;
      
      return h.response({
        success: false,
        error: {
          message: error.message,
          statusCode: statusCode
        }
      }).code(statusCode);
    }
    
    return h.continue;
  });

  // Start server
  await server.start();
  console.log('🚀 HabitVerse API Server running on %s', server.info.uri);
  console.log('📚 API Documentation: %s/api', server.info.uri);
  console.log('❤️  Health Check: %s/api/health', server.info.uri);
  
  return server;
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled rejection:', err);
  process.exit(1);
});

// Handle SIGINT (Ctrl+C)
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down server...');
  process.exit(0);
});

// Start server
init().catch((err) => {
  console.error('❌ Server startup failed:', err);
  process.exit(1);
});

module.exports = { init };
