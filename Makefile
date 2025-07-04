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

ORG_FILES := $(wildcard src/*.org)
HTML_FILES := $(patsubst src/%.org,%.html,$(ORG_FILES))
HEADER_TEMPLATE := assets/html/header.html.in

.PHONY: all clean

all: $(HTML_FILES)

%.html: src/%.org $(HEADER_TEMPLATE)
	@echo "Generating $@ from $<"
	emacs --batch -l org --eval "(find-file \"$<\")" \
	       --eval '(org-html-export-to-html)' --eval '(kill-emacs)'

	mv src/$*.html $@

	INPUT_ORG="$<" HEADER_TEMPLATE="$(HEADER_TEMPLATE)" \
	awk -f scripts/inject-html-header.awk $@ > $@.tmp && mv $@.tmp $@

clean:
	rm -f *.html
