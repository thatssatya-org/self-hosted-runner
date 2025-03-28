FROM ubuntu:24.04

# Set GitHub runner version
ARG RUNNER_VERSION="2.323.0"

# Install required dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev libicu-dev python3 python3-venv python3-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*  # Cleanup to reduce image size

# Create a non-root user for running the GitHub Actions runner
RUN useradd -m docker

# Set working directory
WORKDIR /home/docker/actions-runner

# Download and extract the GitHub Actions runner
RUN curl -L -o actions-runner-linux-arm64.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-arm64.tar.gz \
    && rm actions-runner-linux-arm64.tar.gz  # Cleanup tarball to save space

# Install additional dependencies for the runner
RUN chown -R docker /home/docker && ./bin/installdependencies.sh

# Copy the start script and make it executable
COPY start.sh /home/docker/actions-runner/start.sh
RUN chmod +x /home/docker/actions-runner/start.sh

# Switch to the non-root user
USER docker

# Set the entrypoint
ENTRYPOINT ["./start.sh"]
