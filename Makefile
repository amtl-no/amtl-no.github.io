# SPDX-License-Identifier: GPL-3.0-or-later
# This file is part of the amtl-no.github.io project.
# Copyright (C) 2025 Arne Magnus Tveita Løken
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

OUTPUT_DIR := output
ASSET_DIR := assets
TEMPLATE_DIR := templates
TOOLS_DIR := tools
STATIC_FILES := robots.txt
SITE_CONFIG := site.conf

STYLE_VERSION := $(shell git log -n 1 --pretty=format:%h -- assets/css/style.css 2>/dev/null || echo unknown)

ORG_FILES := $(wildcard src/*.org)
HTML_FILES := $(patsubst src/%.org,%.html,$(ORG_FILES))

HEADER_TEMPLATE := $(TEMPLATE_DIR)/html/header.html.in

VNU_JAR := $(TOOLS_DIR)/vnu.jar
VALIDATION_DIR := $(OUTPUT_DIR)/validation

include $(SITE_CONFIG)

.PHONY: all clean copy-assets copy-static download-vnu validate

all: $(HTML_FILES) copy-assets copy-static validate

%.html: src/%.org $(HEADER_TEMPLATE) $(SITE_CONFIG)
	@echo "Generating $@ from $<"
	mkdir -p $(OUTPUT_DIR)
	emacs --batch -l org \
	  --eval '(setq org-html-doctype "html5")' \
	  --eval '(setq org-html-html5-fancy t)' \
	  --eval "(find-file \"$<\")" \
	  --eval '(org-html-export-to-html)' \
	  --eval '(kill-emacs)'
	mv src/$*.html $@

	@echo "Injecting header into $@"
	@INPUT_ORG="$<" HEADER_TEMPLATE="$(HEADER_TEMPLATE)" DOMAIN="$(DOMAIN)" STYLE_VERSION="$(STYLE_VERSION)" \
	awk -f scripts/inject-html-header.awk $@ > $(OUTPUT_DIR)/$*.html || { echo 'Header injection failed'; exit 1; }
	@rm -f $@

	@echo "Tidying $(OUTPUT_DIR)/$*.html"
	tidy -m -utf8 -quiet -indent --drop-empty-elements yes --show-warnings no $(OUTPUT_DIR)/$*.html || true

	@echo "Injecting validation badge into $@"
	@VALIDATION_JSON="$(VALIDATION_DIR)/$*.json" \
	awk -f scripts/inject-validation-status.awk $(OUTPUT_DIR)/$*.html > $(OUTPUT_DIR)/$*.tmp && mv $(OUTPUT_DIR)/$*.tmp $(OUTPUT_DIR)/$*.html

copy-assets:
	mkdir -p $(OUTPUT_DIR)/$(ASSET_DIR)
	cp -r $(ASSET_DIR)/* $(OUTPUT_DIR)/$(ASSET_DIR)/

copy-static:
	mkdir -p $(OUTPUT_DIR)
	cp $(STATIC_FILES) $(OUTPUT_DIR)/

download-vnu:
	mkdir -p $(TOOLS_DIR)
	test -f $(VNU_JAR) || curl -fL -o $(VNU_JAR) https://github.com/validator/validator/releases/download/latest/vnu.jar

validate: download-vnu $(HTML_FILES)
	mkdir -p $(VALIDATION_DIR)
	for file in $(OUTPUT_DIR)/*.html; do \
		name=$$(basename $$file .html); \
		java -jar $(VNU_JAR) --skip-non-html --format json $$file \
	  		> $(VALIDATION_DIR)/$$name.json 2>&1 || true; \
	done

clean:
	rm -rf $(OUTPUT_DIR)
