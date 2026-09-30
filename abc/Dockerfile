ARG GO_VERSION=1.25.3
ARG PLAYWRIGHT_VERSION=0.5200.0
# Released 2025-06-18
ARG GOTESTSUM_VERSION=1.13.0

FROM golang:${GO_VERSION}-bookworm

ARG PLAYWRIGHT_VERSION
ARG GOTESTSUM_VERSION

# Install system utilities and browser dependencies for Playwright
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg \
        fonts-unifont fonts-dejavu \
        && rm -rf /var/lib/apt/lists/*

# Go environment setup
ENV GOPATH=/go
ENV PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"
ENV GO111MODULE=on

# Install Go tools & Playwright
RUN mkdir -p /tmp/tools && cd /tmp/tools && go mod init tools && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/b4b4r07/iap_curl@latest && \
    go install gotest.tools/gotestsum@v${GOTESTSUM_VERSION} && \
    go install github.com/t-yuki/gocover-cobertura@latest && \
    go install github.com/playwright-community/playwright-go/cmd/playwright@v${PLAYWRIGHT_VERSION} && \
    rm -rf /tmp/tools
RUN playwright install --with-deps 

CMD ["sh"]