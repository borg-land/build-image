FROM alpine:3.11
LABEL description="A Slim Docker Image with Google SDK + Kubectl + Hashicorp Tools."
LABEL "maintainer"="Borg <cy@borg.dev>"
LABEL "terraform version"="0.12.18"
LABEL "kubectl version"="v1.16.2"


# Google SDK
# https://github.com/GoogleCloudPlatform/cloud-sdk-docker/blob/master/alpine/Dockerfile
ARG CLOUD_SDK_VERSION="274.0.0"
ARG TERRAFORM_VERSION="0.12.18"
ARG PACKER_VERSION="1.5.0"
ARG VAULT_VERSION="1.3.0"
ARG KUBECTL_VERSION="v1.16.2"
ENV PYTHONUNBUFFERED=1
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV PATH /google-cloud-sdk/bin:$PATH

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
    #apk add --no-cache --virtual .build-deps python3-dev gcc build-base \
    #&& pip install pylint yamllint \
    #&& apk del .build-deps
    
RUN apk --no-cache add \
        curl \
        make \
        unzip \
        jq \
        py3-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    ## Terraform + Packer + Vault + Kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
    curl https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip  -o /tmp/packer.zip && \
    curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o /tmp/vault.zip && \
    cd /tmp && unzip '*.zip' && \
    mv terraform packer vault /usr/local/bin && rm -rf /tmp/*    
    pip install pylint yamllint
