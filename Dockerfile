# Use the official Grafana image as base
FROM grafana/grafana:latest

# Set the Grafana admin user and password (for initial setup)
ENV GF_SECURITY_ADMIN_USER=admin
ENV GF_SECURITY_ADMIN_PASSWORD=admin

# Expose the Grafana web server port
EXPOSE 3000

# Set up volume for persistent storage
VOLUME ["/var/lib/grafana"]

# Health check to verify Grafana is running properly
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1

# The entrypoint and cmd are inherited from the base image
# No need to specify them again unless you want to override