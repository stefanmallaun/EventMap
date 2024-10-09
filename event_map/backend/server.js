const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());


const config = {
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'eventmap',
    port: 3306,
};


const pool = mysql.createPool(config);


app.post('/api/save-position', async (req, res) => {
    console.log('Request body:', req.body); 
    const {latitude, longitude } = req.body;

    if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Address, latitude, and longitude are required' });
    }

    try {
        const [result] = await pool.query(
            'INSERT INTO locations (latitude, longitude) VALUES (POINT(?, ?), POINT(?, ?))',
            [latitude, longitude, latitude, longitude]
        );
        res.status(200).json({ message: 'Position saved successfully', location_id: result.insertId });
    } catch (err) {
        console.error('Error inserting position:', err.message);
        res.status(500).json({ error: err.message });
    }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
