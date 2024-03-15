# Use python:3.11 as base image
FROM python:3.11

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Convert CRLF to LF in start.sh
# RUN apt-get update && apt-get install -y dos2unix && dos2unix start.sh && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*

# Make start.sh script executable
RUN chmod +x start.sh

# Expose port 8000 to the outside world
EXPOSE 8000

# Run start.sh when the container launches
CMD ["./start.sh"]