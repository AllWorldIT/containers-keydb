#!/bin/bash
# Copyright (c) 2022-2025, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


fdc_test_start keydb "Testing KeyDB..."

KEYDB_PASSWORD=${KEYDB_PASSWORD:-$REDIS_PASSWORD}

if [ -n "$KEYDB_PASSWORD" ]; then
	fdc_test_progress keydb "Testing with password"
	export REDISCLI_AUTH=$KEYDB_PASSWORD
fi

if ! keydb-cli INCR testcounter | grep -E "^1$"; then
	fdc_test_fail keydb "Failed to execute KeyDB INCR"
	false
fi

unset REDISCLI_AUTH

fdc_test_pass keydb "KeyDB test for INCR passed"
