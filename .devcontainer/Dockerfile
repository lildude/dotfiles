FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      bat \
      eza \
      fd-find \
      grc \
      build-essential \
      coreutils \
      gnupg2 \
      jq \
      unzip \
      vim \
      zsh \
      zsh-autosuggestions \
      ripgrep && \
      # curl -sLO https://github.com/sharkdp/hyperfine/releases/download/v1.12.0/hyperfine_1.12.0_amd64.deb && \
      # sudo dpkg -i hyperfine_1.12.0_amd64.deb && \
      # rm hyperfine_1.12.0_amd64.deb && \
      locale-gen "en_GB.UTF-8" "en_US.UTF-8" && \
      apt-get clean

ENV LANG=en_GB.UTF-8 LANGUAGE=en_GB:en LC_ALL=en_GB.UTF-8
