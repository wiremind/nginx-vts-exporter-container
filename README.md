# nginx-vts-exporter-container

This repository builds a container image based on the `docker.io/nginxinc/nginx-unprivileged` image with the [nginx-module-vts](https://github.com/vozlt/nginx-module-vts) compiled as a dynamic module.

The image is automatically built and published to GitHub Container Registry.

## Usage

```bash
docker run ghcr.io/<owner>/<repo>:latest
# or pin to a specific combination of versions
docker run ghcr.io/<owner>/<repo>:nginx-<NGINX_VERSION>-vts-<VTS_VERSION>
```
