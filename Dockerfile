FROM golang:1.16.6-alpine3.14 as builder

# Set the working directory
WORKDIR /build

# Copy only the go.mod and go.sum files initially to cache dependencies
COPY go.mod go.sum ./

# Download dependencies only if they have changed
RUN go mod download

# Copy the entire project source
COPY . .

# Build the application
RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -o app cmd/server/app.go

# Use a smaller Alpine image for the final image
FROM alpine:3.14

# Copy the built binary from the previous stage
COPY --from=builder /build/app .

# Expose the port
EXPOSE 8080

# Command to run the application
CMD ["./app"]