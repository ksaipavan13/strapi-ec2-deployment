# Use a separate builder image to install dependencies
FROM --platform=linux/amd64 node:18-alpine AS builder

WORKDIR /app

COPY package.json ./

# Install dependencies
RUN npm install

COPY . .

# Build the application (if necessary)
# RUN npm run build

# Create a minimal production image
FROM --platform=linux/amd64 node:18-alpine

WORKDIR /srv/app

# Copy the node_modules and built files from the builder image
COPY --from=builder /app /srv/app

EXPOSE 1337

CMD ["npm", "start"]

