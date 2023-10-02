FROM node:18-alpine as builder

# Set working directory
WORKDIR /usr/app

# Copy "package.json" and "package-lock.json" before other files
# Utilise Docker cache to save re-installing dependencies if unchanged
COPY ./package.json ./

# Install dependencies
RUN npm install

# Copy all files
COPY ./ ./

# Build app
RUN npm run build

# Run container as non-root (unprivileged) user
# The "node" user is provided in the Node.js Alpine base image
USER root

FROM nginx:alpine

WORKDIR /etc/nginx/html/

COPY --from=builder /usr/app/dist /etc/nginx/html/

# Expose the listening port
EXPOSE 80

USER root

COPY ./config/nginx/prod.conf /etc/nginx/conf.d/prod.conf

# ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]