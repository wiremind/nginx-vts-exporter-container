# nginx-vts-exporter-container

This repository builds a container image based on the official `nginx` image with the [nginx-module-vts](https://github.com/vozlt/nginx-module-vts) compiled as a dynamic module.

The image is automatically built and published to GitHub Container Registry.

## Usage

```bash
docker run ghcr.io/<owner>/<repo>:latest
```

## Development

- `Containerfile` defines the build steps.
- GitHub Actions build the image on every push and on a weekly schedule.
- Dependabot monitors the base image version.
