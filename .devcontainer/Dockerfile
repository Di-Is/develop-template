FROM ubuntu:24.04 AS ubuntu_base

# For Ubuntu 24.04
RUN userdel -f -r ubuntu

ENV DEBIAN_FRONTEND=noninteractivew

RUN sed -i.bak -r 's@http://(jp\.)?archive\.ubuntu\.com/ubuntu/?@http://ftp.udx.icscoe.jp/Linux/ubuntu/@g' /etc/apt/sources.list.d/ubuntu.sources
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt update && \
    apt upgrade -y

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt install -y --no-install-recommends \
    locales \
    locales-all
RUN locale-gen en_US.UTF-8


RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    sudo \
    vim

# Install mise (for uv management)
RUN curl https://mise.run | MISE_INSTALL_PATH="/usr/local/bin/mise" sh
COPY mise/999-mise.sh /etc/profile.d/999-mise.sh
COPY mise/config.toml /etc/mise/config.toml

ARG USER_ID
ARG _USERNAME=ubuntu
ARG _HOME=/home/${_USERNAME}
ARG _WORKSPACE=${_HOME}/workspace

RUN groupadd -g $USER_ID $_USERNAME && \
    useradd -m -u $USER_ID -g $USER_ID -s /bin/bash $_USERNAME
RUN echo "$_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${_USERNAME}
WORKDIR ${_WORKSPACE}

ENV UV_CACHE_DIR=${_WORKSPACE}/.cache/uv/cache
ENV UV_PYTHON_INSTALL_DIR=${_WORKSPACE}/.cache/uv/python
ENV UV_TOOL_DIR=${_WORKSPACE}/.cache/uv/tool
ENV UV_TOOL_BIN_DIR=${_WORKSPACE}/.cache/uv/tool_bin
ENV PATH=${PATH}:${_HOME}/.local/bin:${_WORKSPACE}/.cache/uv/tool_bin

RUN mkdir ${_HOME}/.vscode-server ${_HOME}/.local ${_HOME}/.config
