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

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
