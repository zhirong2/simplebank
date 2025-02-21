# Build Stage
FROM golang:1.23.4-alpine3.21 AS builder
# Set the Current Working Directory inside the container
WORKDIR /app
# Copy go mod and sum files
COPY . .
RUN go build -o main main.go
RUN apk add curl

# Download and extract the migrate binary
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.18.1/migrate.linux-amd64.tar.gz | tar xvz -C /app

# Verify that the migrate binary exists
RUN ls -l /app/migrate

#Run Stage
FROM alpine:3.21
WORKDIR /app
# Copy the Pre-built binary file from the previous stage to the /app folder in the new stage
COPY --from=builder /app/main .
# COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./db/migration

# Ensure start.sh has execute permissions
RUN chmod +x wait-for.sh
RUN chmod +x start.sh

EXPOSE 8080
ENTRYPOINT [ "/app/start.sh" ]
CMD ["/app/main"]


