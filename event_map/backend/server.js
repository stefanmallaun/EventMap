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
    const {latitude, longitude, address} = req.body;

    if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Address, latitude, and longitude are required' });
    }

    try {
        const [result] = await pool.query(
            'INSERT INTO Location (address, latitude, longitude) VALUES (?,POINT(?, ?), POINT(?, ?))',
            [address, latitude, longitude, latitude, longitude]
        );
        res.status(200).json({ message: 'Position saved successfully', location_id: result.insertId });
    } catch (err) {
        console.error('Error inserting position:', err.message);
        res.status(500).json({ error: err.message });
    }
});
app.post('/api/save-eventdata', async (req, res) => {
    console.log('Request body:', req.body); 
    const {location_id, title, description, event_date, type_of_event} = req.body;

    if (!location_id || !title || !description || !event_date || !type_of_event) {
        return res.status(400).json({ message: 'location_id, title, description, event_date, and type_of_event are required' });
    }

    try {
        const [result] = await pool.query(
            'INSERT INTO Event (location_id, title, description, event_date, type_of_event) VALUES (?,?,?,?,?)',
            [location_id, title, description, event_date, type_of_event]
        );
        res.status(200).json({ message: 'Event data saved successfully', event_id: result.insertId });
    } catch (err) {
        console.error('Error inserting event data:', err.message);
        res.status(500).json({ error: err.message });
    }
});



const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
