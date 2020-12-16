FROM microsoft/azure-cli

LABEL Name="Cloud Tools"
LABEL Maintainer="Gary Golub <gary.golub@lexisnexisrisk.com>"
LABEL Description="Provides environment and scripts to work with Azure (azure cli, powershell, terraform, vault)"
LABEL Version="0.1"

ENV K8S_VERSION 1.19.0
ENV PS_VERSION 7.0.3
ENV TF_VERSION 0.13.2
ENV VAULT_VERSION 1.5.3
ENV FLUX_VERSION 1.21.0
ENV SENTINEL_VERSION 0.16.1
ENV KUBECONFIG=/host_kube_dir/config

# set the working directory
WORKDIR /app

# install PowerShell dependencies
RUN apk update && \
    apk add --no-cache \
    ca-certificates \
    curl \
    icu-libs \
    krb5-libs \
    less \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    ncurses-terminfo-base \
    openssl \
    tzdata \
    userspace-rcu \
    zlib && \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust

# install kubectl
#RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm ./get_helm.sh && \
    rm /var/cache/apk/*

# install vault cli
RUN ZIPFILE=vault_${VAULT_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/${ZIPFILE} && \
    unzip ./${ZIPFILE} -d /usr/local/bin && \
    rm -f ./${ZIPFILE} && \
    vault -autocomplete-install

# install sentinel cli
RUN ZIPFILE=sentinel_${SENTINEL_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/sentinel/${SENTINEL_VERSION}/${ZIPFILE} && \
    unzip ./${ZIPFILE} -d /usr/local/bin && \
    rm -f ./${ZIPFILE}

# install terraform cli
RUN ZIPFILE=terraform_${TF_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/terraform/${TF_VERSION}/${ZIPFILE} && \
    unzip ./${ZIPFILE} -d /usr/local/bin && \
    rm -f ./${ZIPFILE}

# install flux cli
RUN wget https://github.com/fluxcd/flux/releases/download/${FLUX_VERSION}/fluxctl_linux_amd64 -O /usr/local/bin/fluxctl && \
    chmod +x /usr/local/bin/fluxctl

# fetch the PowerShell tar and install PowerShell
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/powershell-${PS_VERSION}-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz && \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    rm /tmp/powershell.tar.gz

# add the Azure module
RUN echo 'Install-Module -Name Az -AllowClobber -Confirm:$False -Force' | pwsh

COPY ./bootstrap.rc /root/.bootstrap.rc
RUN echo '' >> ~/.bashrc && \
    echo "source ~/.bootstrap.rc" >> ~/.bashrc

# save a hidden copy of this file inside the image
COPY Dockerfile /.Dockerfile

#ENV SUBSCRIPTION_NAME infrastructure-sandbox
ENV SUBSCRIPTION_NAME us-infrastructure-dev

COPY keys/* /root/.ssh/
RUN mkdir ~/.kube && \
    touch ~/.kube/config && \
    chmod -R 600 ~/

# remove shells to prevent interactive use of the container
#RUN /bin/rm -R /bin/bash /bin/sh

ENTRYPOINT ["/bin/bash"]
