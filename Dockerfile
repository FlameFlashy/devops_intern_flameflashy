# main image
FROM ubuntu:22.04

# copy scripts and files + .env 
COPY backup.sh /
COPY .env /
COPY ssh_key /
COPY ssh_key.pub /

# create volume
VOLUME /output

# work dir
WORKDIR /

# install dependencies
RUN apt-get update && apt-get install -y \
    openssh-client \
    git

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 600 ssh_key ssh_key.pub

# run command with arguments 
CMD ["bash", "backup.sh", "--max-backups", "5"] 