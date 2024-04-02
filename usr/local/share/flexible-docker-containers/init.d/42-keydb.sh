#!/bin/bash
# Copyright (c) 2022-2024, AllWorldIT.
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


fdc_notice "Setting up KeyDB permissions"
chown root:keydb /var/lib/keydb
chmod 0770 /var/lib/keydb
# Fix main config perms
chmod 0640 /etc/keydb/keydb.conf
chown root:keydb /etc/keydb/keydb.conf

fdc_notice "Initializing KeyDB settings"

# Default o using REDIS_PASSWORD if KEYDB_PASSWORD is not set
export KEYDB_PASSWORD=${KEYDB_PASSWORD:-$REDIS_PASSWORD}

# Setup the password
if [ -n "$KEYDB_PASSWORD" ] || [ -e /etc/keydb/users.acl ]; then
	fdc_info "Enabling KeyDB user ACL"
	# Setup default user
	if [ -n "$KEYDB_PASSWORD" ] && [ ! -s /etc/keydb/users.acl ]; then
		fdc_info "Setting KeyDB password"
		echo "user default on +@all ~* &* >$KEYDB_PASSWORD" > /etc/keydb/users.acl
	fi
fi

chmod 0640 /etc/keydb/users.acl
chown root:keydb /etc/keydb/users.acl
