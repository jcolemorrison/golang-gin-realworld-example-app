# build the AMD and ARM bins
FROM golang:1.17.0 AS builder
WORKDIR /go/src/app/
COPY . .
RUN GOOS=linux GOARCH=amd64 go build -o ./bin/amd64/api hello.go
RUN GOOS=linux GOARCH=arm64 go build -o ./bin/arm64/api hello.go

# prepare the image for AMD
FROM golang:1.17.0 AS image-amd64
WORKDIR /usr/local/bin/
COPY --from=builder /go/src/app/bin/amd64/api .

# prepare the image for ARM
FROM golang:1.17.0 AS image-arm64
WORKDIR /usr/local/bin/
COPY --from=builder /go/src/app/bin/arm64/api .

# Use the image based on the architecture.  Built Docker variable, $TARGETARCH, to get this information.
# Use one of the two prepared images.  Since this is a multi-stage build, the above will not be included in the final image
FROM image-${TARGETARCH}
RUN chmod +x ./api
ENTRYPOINT ["./api"]