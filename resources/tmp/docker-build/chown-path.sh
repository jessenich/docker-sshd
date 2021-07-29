#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

if [ -n "$ECHOWNDIRS" ]; then
   if [ ! -d "$ECHOWNDIRS" ]; then
      mkdir -p "$ECHOWNDIRS"
   fi

   chown "$EUSER":"$EGROUP" "$ECHOWNDIRS"
fi

if [ -n "$ECHOWNFILES" ]; then
   if [ ! -f "$ECHOWNFILES" ]; then
      touch "$ECHOWNFILES"
   fi

   chown "$EUSER":"$EGROUP" "$ECHOWNFILES"
fi