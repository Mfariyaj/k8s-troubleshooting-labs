const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(helmet());
app.use(morgan('combined'));
app.use(compression());
app.use(express.json());

// Products endpoint
app.get('/api/products', (req, res) => {
  res.json([
    { id: uuidv4(), name: 'Widget', price: 9.99 },
    { id: uuidv4(), name: 'Gadget', price: 19.99 },
    { id: uuidv4(), name: 'Doohickey', price: 29.99 },
  ]);
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`E-commerce API running on port ${PORT}`);
});
