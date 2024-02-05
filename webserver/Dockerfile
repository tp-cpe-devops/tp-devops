# Use the Apache HTTP Server image
FROM httpd:latest

# Copy the index.html file to the htdocs directory of Apache
COPY index.html /usr/local/apache2/htdocs/

# Copy the Apache configuration file into the container
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Expose port 80
EXPOSE 80
