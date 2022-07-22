FROM debian:bullseye-slim

ARG GCLOUD_CORE_VERSION=394.0.0-0
ARG GCLOUD_AUTH_VERSION=394.0.0-0
ARG KUBECTL_VERSION=1.23.5
ARG HELM_VERSION=3.8.1
ARG HELM_DIFF_VERSION=3.4.2
ARG HELM_SECRETS_VERSION=3.12.0
ARG HELMFILE_VERSION=0.144.0
ARG HELM_S3_VERSION=0.10.0
ARG HELM_GIT_VERSION=0.11.1
ARG TARGETARCH

WORKDIR /

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl /usr/local/bin/kubectl
ADD https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz /tmp
ADD https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_${TARGETARCH} /usr/local/bin/helmfile

RUN apt update -y && apt install -y apt-transport-https git gnupg curl gettext jq unzip sudo python3-pip apt-transport-https \
    ### Install Gcloud dependencies
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
    && apt update -y && apt install -y google-cloud-cli=${GCLOUD_CORE_VERSION} google-cloud-sdk-gke-gcloud-auth-plugin=${GCLOUD_AUTH_VERSION} \
    && pip3 install ec2instanceconnectcli \
    && tar -zxvf /tmp/helm* -C /tmp \
    && mv /tmp/linux-${TARGETARCH}/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/kubectl \
    ### Install Helm + plugins
    && helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} \
    && helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} \
    && helm plugin install https://github.com/hypnoglow/helm-s3.git --version ${HELM_S3_VERSION} \
    && helm plugin install https://github.com/aslafy-z/helm-git --version ${HELM_GIT_VERSION} \
    && chmod 0755 /usr/local/bin/helmfile \
    ### Clean up
    && apt autoclean && apt autoremove \
    && rm -rf /tmp/*

ENTRYPOINT ["/usr/local/bin/helmfile"]
