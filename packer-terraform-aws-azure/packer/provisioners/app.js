/*Esta aplicación Node.js está configurada para escuchar en el puerto 3000 y responde con el mensaje definido en el código cuando se 
accede a la URL raíz (/). Este comportamiento básico permite comprobar rápidamente que el servidor está funcionando correctamente.
Para cualquier otra ruta diferente de /, la aplicación devuelve un código de error "404 Not Found", indicando que la ruta solicitada
no está disponible. Esta estructura sencilla es ideal como punto de partida para desarrollar aplicaciones web más complejas, ya que
establece una ruta principal de respuesta y una gestión básica de errores para rutas no definidas.*/


const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('App Node.JS. Actividad#1 Realizada Correctamente.\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});