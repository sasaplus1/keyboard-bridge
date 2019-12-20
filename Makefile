.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

projects := $(basename $(wildcard *.pro))

dist_files := $(addprefix dist/,$(addsuffix -main.pdf,$(projects)) $(addsuffix -dimensions.pdf,$(projects)))
dist_zips := $(addprefix dist/,$(addsuffix .zip,$(projects)))

checksum_file := sha256sum.txt

dist/%.zip: %-main.pdf %-dimensions.pdf
	zip -j $@ $^

%-main.pdf: %-Edge_Cuts.pdf
	cp $< $@

%-dimensions.pdf: %-Dwgs_User.pdf
	cp $< $@

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: build
build: $(dist_zips) ## packaging acrylic files to zip for Elecrow
	@printf -- 'generate %s\n' "$(dist_zips)"

.PHONY: clean
clean: ## remove some generated files
	$(RM) $(dist_files) $(dist_zips)

.PHONY: create_checksum
create_checksum: ## create checksum file
	shasum --algorithm 256 $(dist_zips) | awk '{ last = split($$2, file, "/"); print $$1 "  " file[last] }' > $(checksum_file)

.PHONY: info
info: ## show archive infomations
	printf -- '%s' "$(dist_zips)" | tr ' ' '\n' | xargs -n 1 zipinfo
