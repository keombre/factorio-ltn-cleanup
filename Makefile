VERSION := $(shell jq -r .version src/info.json)
BUILD := ./build

all: zip

zip:
	rm -rf $(BUILD)
	mkdir -p $(BUILD)
	cp -r ./src $(BUILD)/ltn-cleanup_$(VERSION)
	cd $(BUILD) && zip -r ./ltn-cleanup_$(VERSION).zip ./ltn-cleanup_$(VERSION) && cd ..
	rm -r $(BUILD)/ltn-cleanup_$(VERSION)
