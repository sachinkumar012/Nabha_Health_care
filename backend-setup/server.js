// Simple Node.js Express backend for chat storage
// Deploy this to services like Vercel, Netlify Functions, or Railway

const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Create data directory if it doesn't exist
const DATA_DIR = path.join(__dirname, 'chat-data');
const ensureDataDir = async () => {
  try {
    await fs.access(DATA_DIR);
  } catch {
    await fs.mkdir(DATA_DIR, { recursive: true });
  }
};

// Helper function to get file path for session
const getSessionFilePath = (sessionId) => {
  return path.join(DATA_DIR, `${sessionId}.json`);
};

// Save chat history
app.post('/api/chat/save', async (req, res) => {
  try {
    const { sessionId, messages, timestamp } = req.body;
    
    if (!sessionId || !messages) {
      return res.status(400).json({ error: 'Missing sessionId or messages' });
    }

    await ensureDataDir();
    
    const chatData = {
      sessionId,
      messages,
      lastUpdated: timestamp || new Date().toISOString(),
      messageCount: messages.length
    };

    const filePath = getSessionFilePath(sessionId);
    await fs.writeFile(filePath, JSON.stringify(chatData, null, 2));

    res.json({ 
      success: true, 
      message: 'Chat saved successfully',
      messageCount: messages.length 
    });
  } catch (error) {
    console.error('Error saving chat:', error);
    res.status(500).json({ error: 'Failed to save chat' });
  }
});

// Load chat history
app.get('/api/chat/load', async (req, res) => {
  try {
    const { sessionId } = req.query;
    
    if (!sessionId) {
      return res.status(400).json({ error: 'Missing sessionId' });
    }

    const filePath = getSessionFilePath(sessionId);
    
    try {
      const data = await fs.readFile(filePath, 'utf8');
      const chatData = JSON.parse(data);
      
      res.json({
        success: true,
        messages: chatData.messages,
        lastUpdated: chatData.lastUpdated,
        messageCount: chatData.messageCount
      });
    } catch (error) {
      // File doesn't exist - return empty result
      res.json({
        success: true,
        messages: [],
        messageCount: 0
      });
    }
  } catch (error) {
    console.error('Error loading chat:', error);
    res.status(500).json({ error: 'Failed to load chat' });
  }
});

// Clear chat history
app.post('/api/chat/clear', async (req, res) => {
  try {
    const { sessionId } = req.body;
    
    if (!sessionId) {
      return res.status(400).json({ error: 'Missing sessionId' });
    }

    const filePath = getSessionFilePath(sessionId);
    
    try {
      await fs.unlink(filePath);
    } catch (error) {
      // File might not exist - that's okay
    }

    res.json({ 
      success: true, 
      message: 'Chat cleared successfully' 
    });
  } catch (error) {
    console.error('Error clearing chat:', error);
    res.status(500).json({ error: 'Failed to clear chat' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// List all sessions (for admin purposes)
app.get('/api/chat/sessions', async (req, res) => {
  try {
    await ensureDataDir();
    const files = await fs.readdir(DATA_DIR);
    const sessions = files
      .filter(file => file.endsWith('.json'))
      .map(file => file.replace('.json', ''));
    
    res.json({ 
      success: true, 
      sessions,
      count: sessions.length 
    });
  } catch (error) {
    console.error('Error listing sessions:', error);
    res.status(500).json({ error: 'Failed to list sessions' });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Chat Storage Server running on port ${PORT}`);
  console.log(`📁 Data directory: ${DATA_DIR}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/api/health`);
});