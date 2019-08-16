FROM alpine:3.9
LABEL description="A Docker Image with Google SDK + Misc Tools."
ARG CLOUD_SDK_VERSION=258.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV PATH /google-cloud-sdk/bin:$PATH

# Tools
RUN apt-get update && apt-get install curl wget net-tools unzip gnupg -y && \
    rm -rf /var/lib/apt/lists/*

# Google SDK
RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
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
    gcloud --version

## Terraform + Packer

ARG TERRAFORM_VERSION="0.12.6"
ARG PACKER_VERSION="1.4.0"
ARG VAULT_VERSION="1.1.1"

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/terraform.zip
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip /tmp/packer.zip
ADD https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip /tmp/vault.zip

RUN cd /tmp && \
    unzip '*.zip' &&  \
    mv terraform packer vault /usr/local/bin


