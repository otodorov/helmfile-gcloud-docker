# helmfile-gcloud-docker

Helmfile with gcloud authenticator

Building new image:

```bash
docker build -t europe-docker.pkg.dev/<project name>/docker-images/helmfile-gcloud-docker:2.0.0 .
docker push europe-docker.pkg.dev/<project name>/docker-images/helmfile-gcloud-docker:2.0.0
```

DO NOT FORGET TO INCREASE IMAGE TAG!!!

This process will be automated in the future.
