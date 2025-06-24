FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    sudo \
    zip \ 
    unzip \
    ca-certificates \
    libicu66 \
    libkrb5-3 \
    zlib1g \
    libssl1.1 \
    libcurl4 \
    && apt-get clean

# Create non-root user for the runner
RUN useradd -m runner

# Set up working directory
WORKDIR /actions-runner

# Download and extract GitHub Actions runner
ARG RUNNER_VERSION=2.316.0
RUN curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use non-root user
USER runner

ENTRYPOINT ["/entrypoint.sh"]
