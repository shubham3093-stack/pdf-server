const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

// Enable CORS for all requests
app.use(cors());

// Serve static files from the "public" folder
app.use('/pdfs', express.static(path.join(__dirname, 'public')));

// Start the server
app.listen(PORT, () => {
  console.log(`PDF server running at http://localhost:${PORT}/pdfs`);
});
