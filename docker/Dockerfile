# syntax=docker/dockerfile:1
# Forge Neo | NVIDIA GPU

# CUDA 13 / sm_120 for Blackwell GPUs (RTX 50xx)
ARG CUDA_VERSION=13.0.2

FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu24.04

# See: https://download.pytorch.org/whl/
ARG TORCH_INDEX=cu130
ARG TORCH_VERSION=2.14.0
ARG TORCHVISION_VERSION=0.29.0

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PYTHON_DOWNLOADS=automatic \
    UV_NO_CACHE=1 \
    TORCH_INDEX_URL=https://download.pytorch.org/whl/${TORCH_INDEX}

# uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ffmpeg \
        git \
        libgl1 \
        libglib2.0-0t64 \
        libgomp1 \
        libtcmalloc-minimal4t64 \
        openssh-server \
        rsync \
        wget \
    && rm -rf /var/lib/apt/lists/*

# SSH (root login via public key only)
RUN mkdir -p /run/sshd \
    && printf '%s\n' \
        'PermitRootLogin without-password' \
        'PasswordAuthentication no' \
        'PubkeyAuthentication yes' \
        > /etc/ssh/sshd_config.d/50-root.conf

# Non-Root User (UID 99 / GID 100 = nobody:users)
RUN groupadd -g 100 users 2>/dev/null || true \
    && useradd -u 99 -g 100 -d /home/forge -m -s /bin/bash forge

WORKDIR /home/forge/sd-webui

# Invalidate the cache when upstream (Neo) updates
ADD https://api.github.com/repos/Haoming02/sd-webui-forge-classic/commits/neo /tmp/neo-rev.json

# Clone at build time
RUN git clone --branch neo --depth 1 --filter blob:none \
        https://github.com/Haoming02/sd-webui-forge-classic.git . \
    && chown -R 99:100 /home/forge

USER forge

# Python 3.13 Virtual ENVironment
RUN uv venv venv --python 3.13 --seed

ENV VIRTUAL_ENV="/home/forge/sd-webui/venv" \
    PATH="/home/forge/sd-webui/venv/bin:$PATH" \
    PYTHON="/home/forge/sd-webui/venv/bin/python3.13"

# PyTorch Pre-Install
RUN uv pip install "torch==${TORCH_VERSION}" "torchvision==${TORCHVISION_VERSION}" \
    --index-url "https://download.pytorch.org/whl/${TORCH_INDEX}"

# Persistent Data Directories
RUN mkdir -p \
        models/Stable-diffusion \
        models/VAE \
        models/Lora \
        models/ControlNet \
        extensions \
        config \
        output

# Runtime
COPY --chmod=0755 init.sh /usr/local/bin/init.sh
COPY --chown=99:100 --chmod=0755 entrypoint.sh /home/forge/sd-webui/entrypoint.sh

USER root

EXPOSE 22
EXPOSE 7860

# extra time for prepare_environment() to run on first start
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=15 \
    CMD curl -f http://localhost:7860/ || exit 1

ENTRYPOINT ["/usr/local/bin/init.sh"]
