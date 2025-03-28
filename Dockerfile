FROM ubuntu:24.04 AS build

# Set GitHub runner version
ARG RUNNER_VERSION="2.323.0"

ADD https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
    /home/docker/temp/

# Set working directory
WORKDIR /home/docker/actions-runner

# Download and extract the GitHub Actions runner
RUN tar xzf /home/docker/temp/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && rm -rf /home/docker/temp

# Production image stage
FROM ubuntu:24.04
WORKDIR /home/docker/actions-runner

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq libicu-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /home/docker/actions-runner .

RUN useradd -m docker \
    && chown -R docker /home/docker

# Copy the start script and make it executable
COPY start.sh /home/docker/actions-runner/start.sh
RUN chmod +x /home/docker/actions-runner/start.sh

# Switch to the non-root user
USER docker

# Set the entrypoint
ENTRYPOINT ["./start.sh"]
