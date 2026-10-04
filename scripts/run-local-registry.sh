#!/bin/sh
# Local image registry for home_state's k3s step: registry:2 on 127.0.0.1:5000 only.
# No sudo needed (jamin is in the docker group). Safe to re-run.
# Push:  docker tag IMG localhost:5000/NAME && docker push localhost:5000/NAME
# k3s pulls localhost:5000/NAME (containerd runs in the host netns, so localhost = lenovo).
# Remove: docker rm -f registry && docker volume rm registry-data
set -eu

if docker container inspect registry >/dev/null 2>&1; then
  echo "registry container exists; ensuring it's running"
  docker start registry >/dev/null
else
  # Explicit 127.0.0.1 bind (also the daemon.json default) — published ports bypass ufw.
  docker run -d --name registry --restart unless-stopped \
    -p 127.0.0.1:5000:5000 \
    -v registry-data:/var/lib/registry \
    registry:2
fi

echo "--- container:"; docker ps --filter name=registry --format '{{.Names}}  {{.Image}}  {{.Status}}  {{.Ports}}'
echo "--- catalog:";   curl -fsS http://127.0.0.1:5000/v2/_catalog
