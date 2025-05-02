const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('¡Hola. Actividad #1 desde Node.js desplegada en AWS y Azure!');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Aplicación escuchando en http://localhost:${port}`);
});