FROM hashicorp/terraform:0.11.11

ENV GOPATH=/root/go
ENV PATH="${GOPATH}/bin:${PATH}"
ENV KUBE_VERSION="v1.13.1"

RUN apk update \
    && apk add bash build-base jq python py-pip go \
    && go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator \
    && pip install awscli \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/*

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# ENV AWS_PROFILE=lli
# ENV KUBECONFIG=/dir/terraform/eks/.kube/config