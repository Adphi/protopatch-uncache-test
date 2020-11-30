
export GOBIN=$(PWD)/bin
export PATH := $(PWD)/bin:$(PATH)

.PHONY:
test: test-cached test-no-cache

tools:
	@echo "Installing not cached version"
	@rm -rf bin tmp
	@go install github.com/alta/protopatch/cmd/protoc-gen-go-patch

tools-patched:
	@echo "Installing cache version"
	@rm -rf bin tmp
	@mkdir -p tmp bin
	@cd tmp
	@cd tmp && git clone https://github.com/adphi/protopatch &> /dev/null
	@cd tmp/protopatch && git checkout cache
	@cd tmp/protopatch && make install

clean-tools:
	@echo "Cleaning tools"
	@rm -rf bin
	@rm -rf tmp

.PHONY:
proto: clean-proto
	@echo "Generating proto"
	protoc -I. -Ithird_party --go-patch_out=plugin=go,paths=source_relative:. \
		--go-patch_out=plugin=validate,paths=source_relative,lang=go:. \
		pb/interfaces.proto

.PHONY:
test-no-cache: clean tools proto
	@echo "Testing compilation"
	@-make go-test

.PHONY:
test-cached: clean proto-cached
	@make go-test

.PHONY:
go-test:
	@echo "Testing compilation"
	@-go test -v ./...

proto-cached: tools-patched proto

.PHONY:
clean-proto:
	@echo "Cleaning proto generated files"
	@rm -fr pb/*.pb.go pb/*.pb.*.go

.PHONY:
clean: clean-proto clean-tools
