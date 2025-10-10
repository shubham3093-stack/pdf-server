const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS
app.use(cors());

// Serve static files from /public under /pdfs
app.use('/pdfs', express.static(path.join(__dirname, 'public')));

// Root route (optional)
app.get('/', (req, res) => {
  res.send('PDF Server is running');
});

// NEW: List all available PDFs in /public
app.get('/api/pdfs', (req, res) => {
  const pdfDir = path.join(__dirname, 'public');

  fs.readdir(pdfDir, (err, files) => {
    if (err) {
      return res.status(500).json({ error: 'Unable to read PDF directory' });
    }

    const pdfFiles = files.filter(file => file.toLowerCase().endsWith('.pdf'));

    const baseUrl = `${req.protocol}://${req.get('host')}/pdfs/`;
    const pdfUrls = pdfFiles.map(file => baseUrl + file);

    res.json(pdfUrls);
  });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
