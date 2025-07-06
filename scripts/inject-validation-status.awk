
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

BEGIN {
	validation_json = ENVIRON["VALIDATION_JSON"]
	badge = ""
	href = "validation/" basename(validation_json)

	valid = 1
	while ((getline line < validation_json) > 0) {
		if (line ~ /"messages": \[/ && line !~ /\[\s*\]/) {
			valid = 0
			break
		}
	}

	if (valid) {
		badge = "<span class=\"badge badge-valid\">Valid HTML</span>"
	} else {
		badge = "<span class=\"badge badge-invalid\">Invalid HTML</span>"
	}
}

# Funksjon: basename uten path
function basename(path,   i, parts) {
	n = split(path, parts, "/")
	return parts[n]
}

{
	if ($0 ~ /<p class="validation"><a href=$/) {
		# Dette er første linje i en brutt <a href="..."> tag
		getline    # Les neste linje, som inneholder validator-lenka
		print "<p class=\"validation\"><a href=\"" href "\">Validation status: " badge "</a></p>"
		next       # Hopp over begge linjene
	}

	if ($0 ~ /validator\.w3\.org\/check\?uri=referer/) {
		# fallback hvis hele taggen er på én linje
		print "<p class=\"validation\"><a href=\"" href "\">Validation status: " badge "</a></p>"
		next
	}

	print
}
