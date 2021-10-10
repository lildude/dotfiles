# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.194.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      bat \
      fd-find \
      fzf \
      build-essential \
      coreutils \
      gnupg2 \
      jq \
      unzip \
      zsh \
      neovim && \
      ripgrep && \
    locale-gen "en_GB.UTF-8" "en_US.UTF-8" && \
    apt-get clean

ENV LANG en_GB.UTF-8 LANGUAGE en_GB:en LC_ALL en_GB.UTF-8
