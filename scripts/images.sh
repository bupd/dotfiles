#!/bin/bash

# List of images to pull, tag, and push
images=(
    "ubuntu:20.04"
    "ubuntu:latest"
    "nginx:latest"
    "node:14"
    "node:latest"
    "golang:latest"
    "redis:alpine"
    "redis:latest"
)

# Loop through the images
for image in "${images[@]}"; do
    # Pull the image from Docker Hub
    docker pull $image

    # Tag the image to next.advantage.io
    docker tag $image localhost/library/$image

    # Push the tagged image to the registry
    docker push localhost/library/$image
done

