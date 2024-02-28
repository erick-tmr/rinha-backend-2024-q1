# build stage
FROM golang:1.22 AS build

WORKDIR /app

COPY . /app

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -o /api

# run stage
FROM alpine:latest

WORKDIR /

COPY --from=build /api /api

EXPOSE 8000

# add nonroot user
ENV HOME /home/nonroot

RUN adduser -D nonroot \
        && mkdir -p /etc/sudoers.d \
        && echo "nonroot ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nonroot \
        && chmod 0440 /etc/sudoers.d/nonroot

USER nonroot

ENTRYPOINT [ "/api" ]
