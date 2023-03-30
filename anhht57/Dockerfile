FROM --platform=linux/amd64 golang:1.18rc1-alpine AS build
WORKDIR /src
ENV CGO_ENABLED=0
COPY . .
RUN apk add git
#RUN go get github.com/swaggo/swag/gen@v1.7.6
#RUN go get github.com/swaggo/swag/cmd/swag@v1.7.6
#RUN go install github.com/swaggo/swag/cmd/swag
#RUN swag init
RUN go mod tidy
RUN mkdir -p /out/
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -buildvcs=false -o /out/server ./cmd/server
# FROM scratch AS bin-unix
# FROM bin-unix AS bin-linux
# FROM bin-unix AS bin-darwin
# FROM scratch AS bin-windows
# FROM scratch AS bin
FROM alpine:3.15 AS bin
# RUN apk add bash
WORKDIR /app
COPY ./.env .
COPY ./config.yaml .
COPY --from=build /out/server server
# COPY ./wait-for-it.sh .
# RUN chmod +x wait-for-it.sh
CMD ["./server"]