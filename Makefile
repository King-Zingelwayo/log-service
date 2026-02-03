GOOS        := linux
GOARCH      ?= arm64
CGO         := 0
ARTIFACTS   := cmd/artifacts

LAMBDAS := ingest read-recent

.PHONY: all clean tidy $(LAMBDAS)

all: tidy $(LAMBDAS)

tidy:
	@echo "🧹 Tidying Go modules..."
	go mod tidy

$(LAMBDAS):
	@echo "🔨 Building lambda: $@"
	mkdir -p $(ARTIFACTS)
	# Build the binary specifically named 'bootstrap'
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO) \
	go build -trimpath -ldflags="-s -w" -o cmd/$@/bootstrap ./cmd/$@/main.go
	
	# Zip it as 'bootstrap' into the artifacts folder
	cd cmd/$@ && zip -j ../../$(ARTIFACTS)/$@.zip bootstrap
	
	# Clean up the local bootstrap after zipping
	rm -f cmd/$@/bootstrap

clean:
	rm -rf $(ARTIFACTS)