# Build stage
FROM golang:1.21 AS builder
WORKDIR /sample-k8s
COPY . .
RUN go mod init hello && go mod tidy
RUN go build -o server

# Run stage
FROM gcr.io/distroless/base-debian12
WORKDIR /sample-k8s
COPY --from=builder /sample-k8s/server .
EXPOSE 8080
ENTRYPOINT ["/sample-k8s/server"]
