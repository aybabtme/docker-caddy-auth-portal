#!/bin/bash

set -eu

function version {
    local name=$1
    jq < versions.json -r ".${name}"
}

tag_version=$(version tag)
caddy_version=$(version caddy)
xcaddy_version=$(version xcaddy)
caddy_auth_portal_version=$(version caddy_auth_portal)
caddy_auth_jwt_version=$(version caddy_auth_jwt)
caddy_trace_version=$(version caddy_trace)

image_name="aybabtme/caddy"
image_version="${image_name}:${tag_version}"
image_latest="${image_name}:latest"

HUB_USER=$(op get item Docker | jq -r '.details.fields[] | select(.designation=="username").value')
HUB_PWD=$(op get item Docker | jq -r '.details.fields[] | select(.designation=="password").value')

echo "Logging into Docker Hub"
echo $HUB_PWD | docker login -u $HUB_USER --password-stdin

echo "Building $caddy_version image"
docker build \
    --build-arg CADDY_VERSION=$caddy_version \
    --build-arg XCADDY_VERSION=$xcaddy_version \
    --build-arg CADDY_AUTH_PORTAL_VERSION=$caddy_auth_portal_version \
    --build-arg CADDY_AUTH_JWT_VERSION=$caddy_auth_jwt_version \
    --build-arg CADDY_AUTH_TRACE_VERSION=$caddy_trace_version \
    -t $image_version .
docker tag $image_version $image_latest

echo "Pushing image to Docker Hub"
docker push $image_version
docker push $image_latest
docker rmi $image_version
docker rmi $image_latest