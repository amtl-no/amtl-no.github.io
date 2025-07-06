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

BEGIN {
  infile = ENVIRON["INPUT_ORG"]
  domain = ENVIRON["DOMAIN"]
  style_version = ENVIRON["STYLE_VERSION"]

  canonical_url = "https://" domain   # Sett URL for index.html som root

  # Hvis filen ikke er index.org, sett canonical-url basert på filnavnet
  gsub("^src/", "", infile)  # Fjern 'src/'-prefiks
  gsub(".org$", "", infile)  # Fjern '.org'-suffiks
  if (infile != "index") {
    canonical_url = "https://" domain "/" infile
  }
  
  # Sett canonical URL i headeren
  while ((getline line < ENVIRON["HEADER_TEMPLATE"]) > 0) {
    gsub("@CANONICAL_URL@", canonical_url, line)
    gsub("@INPUT_ORG@", infile, line)
	gsub("@STYLE_VERSION@", style_version, line)
    print line
  }
}

{
  print
}
