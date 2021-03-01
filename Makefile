VERSION := $(shell jq -r .version src/info.json)
BUILD := ./build

all:
	rm -rf $(BUILD)
	mkdir -p $(BUILD)
	cp -r ./src $(BUILD)/ltn-cleanup_$(VERSION)
	zip -r $(BUILD)/ltn-cleanup_$(VERSION).zip $(BUILD)/ltn-cleanup_$(VERSION)
	rm -r $(BUILD)/ltn-cleanup_$(VERSION)
