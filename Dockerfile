# Use nginx alpine as base image for a lightweight container
FROM nginx:alpine

# Set maintainer label
LABEL maintainer="monochrome-docker"
LABEL description="Monochrome - Privacy-respecting TIDAL web UI"

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Clone the monochrome repository
# We'll use wget to download the repository as a zip file since git clone might not work
RUN apk add --no-cache wget unzip && \
    cd /tmp && \
    wget https://github.com/monochrome-music/monochrome/archive/refs/heads/main.zip && \
    unzip main.zip && \
    mv monochrome-main/* /usr/share/nginx/html/ && \
    rm -rf /tmp/main.zip /tmp/monochrome-main && \
    apk del wget unzip

# Create a custom nginx configuration
RUN echo 'server { \n\
    listen 80; \n\
    server_name localhost; \n\
    root /usr/share/nginx/html; \n\
    index index.html; \n\
    \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
    \n\
    # Enable gzip compression \n\
    gzip on; \n\
    gzip_vary on; \n\
    gzip_min_length 1024; \n\
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json; \n\
    \n\
    # Cache static assets \n\
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ { \n\
        expires 1y; \n\
        add_header Cache-Control "public, immutable"; \n\
    } \n\
} \n' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
