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
STATIC_FILES := robots.txt
SITE_CONFIG := site.conf

ORG_FILES := $(wildcard src/*.org)
HTML_FILES := $(patsubst src/%.org,%.html,$(ORG_FILES))

HEADER_TEMPLATE := $(ASSET_DIR)/html/header.html.in

include $(SITE_CONFIG)

.PHONY: all clean copy-assets copy-static

all: $(HTML_FILES) copy-assets copy-static

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
	INPUT_ORG="$<" HEADER_TEMPLATE="$(HEADER_TEMPLATE)" DOMAIN="$(DOMAIN)" \
	awk -f scripts/inject-html-header.awk $@ > $(OUTPUT_DIR)/$*.html && rm -f $@
	@echo "Tidying $(OUTPUT_DIR)/$*.html"
	tidy -m -utf8 -quiet -indent --drop-empty-elements yes --show-warnings no $(OUTPUT_DIR)/$*.html || true

copy-assets:
	mkdir -p $(OUTPUT_DIR)/$(ASSET_DIR)
	cp -r $(ASSET_DIR)/* $(OUTPUT_DIR)/$(ASSET_DIR)/

copy-static:
	mkdir -p $(OUTPUT_DIR)
	cp $(STATIC_FILES) $(OUTPUT_DIR)/


clean:
	rm -f *.html
