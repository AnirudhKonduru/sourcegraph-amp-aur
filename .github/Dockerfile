FROM archlinux:latest

# Install all required packages in one layer
RUN pacman -Syu --noconfirm \
    base-devel \
    git \
    nodejs \
    npm \
    pacman-contrib \
    sudo \
    && pacman -Scc --noconfirm

# Create builder user with sudo privileges
RUN useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set git configuration for the builder user
USER builder
RUN git config --global user.email 'action@github.com' && \
    git config --global user.name 'GitHub Action'

# Switch back to root for workflow execution
USER root

WORKDIR /workspace
