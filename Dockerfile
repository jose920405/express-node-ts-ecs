# Usa una imagen de Node.js como base
FROM --platform=linux/amd64 node:20.10.0-alpine

# Crea el directorio de la aplicación en el contenedor
WORKDIR /app

# Copia los archivos de package.json y package-lock.json
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el código fuente al contenedor
COPY . .

# Compila el código TypeScript
RUN npm run build

# Expone el puerto de la aplicación

# Main
# EXPOSE 8000

# Sign
# EXPOSE 8001

# Default
EXPOSE 80

# Comando para iniciar la aplicación
CMD ["node", "dist/src/index.js"]
