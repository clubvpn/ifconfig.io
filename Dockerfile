FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:alpine as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH


ENV CGO_ENABLED=0
ENV GO111MODULE=on

WORKDIR /build

# Cache the download before continuing
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY main.go .

RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
  go build -tags=jsoniter -o main .

WORKDIR /dist

RUN cp /build/main .

FROM --platform=${BUILDPLATFORM:-linux/amd64} gcr.io/distroless/static:nonroot

WORKDIR /
COPY --from=builder /dist/main /
COPY ./templates /templates
COPY ./LICENSE /LICENSE

USER nonroot:nonroot

CMD ["/main"]