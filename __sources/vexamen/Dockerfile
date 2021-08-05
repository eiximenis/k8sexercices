FROM golang:1.15-alpine AS build
COPY main.go .

WORKDIR /tmp/vexamen
COPY main.go .
RUN go build -o ./out/vexamen-server

FROM alpine:3.12
ARG VERSION
EXPOSE 8080
WORKDIR /app
COPY --from=build /tmp/vexamen/out/vexamen-server .
ENV VEXAMEN_VERSION="${VERSION}"
CMD ["/app/vexamen-server"]