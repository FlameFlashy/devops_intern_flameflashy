# Dockerfile for Backup Script

This Dockerfile is used to build an image intended for running a backup script inside a Docker container.

## Usage

1. Install Docker on your system if you haven't already.
2. Clone this repository:

    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

3. Place your `.env` file in the root directory of the repository.
4. Copy your SSH key (`ssh_key` and `ssh_key.pub`) to the root directory of the repository.

## Building the Image
Execute the following command to build the image:

```bash
docker build -t backup-image .
```
To run the container, use the following command:
```bash
docker run -v <path-to-your-output-directory>:/output backup-image
```
Where <path-to-your-output-directory> is the path to the directory where you want to save the output of the backup script.

## Options
You can change the maximum number of backups by specifying the corresponding argument when running the container:
```bash
docker run -v <path-to-your-output-directory>:/output backup-image --max-backups <number-of-backups>
```
## Dependencies
This image uses the base Ubuntu 22.04 image and installs the following dependencies:

1. openssh-client
2. git


# Docker Compose Setup
This Docker Compose configuration sets up a development environment consisting of a PostgreSQL database, a frontend application, an app server, and an NGINX reverse proxy. 

## Instructions
1. Ensure you have Docker and Docker Compose installed on your machine.
2. Clone this repository to your local machine.
3. Customize environment variables in the .env file according to your needs.
4. Run docker-compose up --build to build and start the containers.
5. Access your application via http://localhost:8000 for the app server and http://localhost:4200 for the frontend.
Feel free to modify the configuration files and Dockerfiles to suit your specific requirements.

### if everything configured correctly, you should see under http://localhost
![Docker-compose](localhost.png)
