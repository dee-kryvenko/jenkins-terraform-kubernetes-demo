FROM hashicorp/terraform:0.11.3

ENV GOPATH=/root/go
ENV PATH="${GOPATH}/bin:${PATH}"
ENV KUBECONFIG=/dir/.kube/config
ENV KUBE_VERSION="v1.13.1"
ENV HELM_VERSION="v2.11.0"

RUN apk update \
    && apk add bash parallel build-base jq python py-pip go \
    && go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator \
    && pip install awscli \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/*

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -L http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | \
    tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm && helm version --client

# ENV AWS_PROFILE=lli