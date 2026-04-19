# Build stage: use Node 22 Alpine image
FROM node:22.16-alpine AS build
WORKDIR /app

# Copy package manifest and install dependencies first for caching
COPY package*.json ./
RUN npm install

# Copy source files and build the static site
COPY . .
RUN npm run build

# Runtime stage: serve content with nginx
FROM nginx:alpine AS runtime

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Override nginx config để support SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
