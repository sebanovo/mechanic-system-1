FROM node:22-bookworm

WORKDIR /workspace

# Basic tools for frontend development and debugging.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Keep the container alive for VS Code remote development.
CMD ["sleep", "infinity"]