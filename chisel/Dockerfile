# Use Debian as the base image
FROM debian:bullseye-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl psmisc screen

# Download and install Chisel using a more reliable method
RUN curl -L https://github.com/jpillora/chisel/releases/download/v1.10.0/chisel_1.10.0_linux_amd64.gz -o chisel.gz && \
    gunzip chisel.gz && \
    chmod +x chisel && \
    mv chisel /usr/local/bin/chisel

# Set environment variables with default values
ENV CHISEL_HOST="0.0.0.0"
ENV CHISEL_PORT=8000
ENV CHISEL_VERBOSE=true
ENV CHISEL_USER="akash"
ENV CHISEL_PASSWORD="strong_password"

# Set a shell form ENTRYPOINT to allow flexible CMD
ENTRYPOINT ["/bin/bash", "-c"]

# Default command for the container, can be overridden
CMD ["exec chisel server --host $CHISEL_HOST --port $CHISEL_PORT --reverse -v --auth $CHISEL_USER:$CHISEL_PASSWORD"]

