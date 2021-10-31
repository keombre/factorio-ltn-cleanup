VERSION := $(shell jq -r .version src/info.json)
BUILD := ./build

all: zip

zip:
	rm -rf $(BUILD)
	mkdir -p $(BUILD)
	rsync -av ./src/ $(BUILD)/ltn-cleanup_$(VERSION) --exclude __debug
	cd $(BUILD) && zip -DX -r ./ltn-cleanup_$(VERSION).zip ./ltn-cleanup_$(VERSION) && cd ..
	rm -r $(BUILD)/ltn-cleanup_$(VERSION)
