FROM nginx:1.25-alpine

COPY nginx /etc/nginx

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
