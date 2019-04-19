# Server Setup

## 1. Description

This git repository contains scripts for setting up remote servers.
It contains both bash scripts to build packages from source,
as well as docker files to build docker images.

## 2. Folders

- `docker/`: this folder contains Dockerfiles and Docker Compose (`docker-compose.yml`) files
  for multi-container builds.
- `dpkg/`: this folder contains build scripts where dependencies are installed via `apt`.
  Mostly for builds on Debian (and possibly also Ubuntu)
- `yum/`: this folder contains build scripts where dependencies are installed via `yum`.
  Mostly for builds on Amazon Linux.
- `scripts/`: this folder contains build scripts that do not involve package managers
  such as `apt`, `yum`, or `apk`.
