FROM golang:1.15-alpine AS build
COPY main.go .

WORKDIR /tmp/bm-api
COPY main.go .
RUN go build -o ./out/bm-api

FROM alpine:3.12
EXPOSE 8080
WORKDIR /app
COPY --from=build /tmp/bm-api/out/bm-api .
CMD ["/app/bm-api"]