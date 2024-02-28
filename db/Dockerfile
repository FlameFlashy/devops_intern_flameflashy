# Use postgres:11 as base image
FROM postgres:11

# Set working directory
WORKDIR /usr/src/app

# Copy .env file containing sensitive information
COPY .env /usr/src/app/.env

# Set environment variables for database
ENV POSTGRES_USER=${DB_USER}
ENV POSTGRES_PASSWORD=${DB_PASSWORD}
ENV POSTGRES_DB=${DB_NAME}

# Add volume to save data from Postgres db
VOLUME ./pg_data:/var/lib/postgresql/data

# Expose the PostgreSQL port
EXPOSE 5432