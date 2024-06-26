# Use an official Node.js runtime as a parent image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application (if needed)
RUN npm run build

# Expose the application port
EXPOSE 1337

# Start the application
CMD ["npm", "start"]

