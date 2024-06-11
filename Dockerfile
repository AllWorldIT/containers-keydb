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


FROM registry.conarx.tech/containers/alpine/edge as builder

ENV KEYDB_VER=6.3.4


# Install libs we need
# ref https://docs.keydb.dev/docs/build
RUN set -eux; \
	true "Installing dependencies"; \
	apk add --no-cache \
		build-base \
		\
		coreutils \
		gcc \
		linux-headers \
		make \
		musl-dev \
		util-linux-dev \
		openssl-dev \
		curl-dev \
		g++ \
		bash \
		git \
		perl \
		libunwind-dev \
		\
		curl


# Download packages
RUN set -eux; \
	mkdir -p build; \
	cd build; \
	true "KeyDB..."; \
	wget "https://github.com/Snapchat/KeyDB/archive/refs/tags/v${KEYDB_VER}.tar.gz" -O "keydb-$KEYDB_VER.tar.gz"; \
	tar -zxf "keydb-${KEYDB_VER}.tar.gz"; \
	cd "KeyDB-$KEYDB_VER"; \
	# Compiler flags
	. /etc/buildflags; \
	\
	true "Build KeyDB..."; \
	KEYDB_DESTDIR=/build/keydb-root; \
	KEYDB_ROOT=/opt/keydb; \
	make -j$(nproc) -l 8 V=1 \
		PREFIX="$KEYDB_ROOT"; \
	true "Install KeyDB..."; \
	make -j$(nprocs) \
		PREFIX="$KEYDB_DESTDIR$KEYDB_ROOT" \
		install; \
	mkdir -p "$KEYDB_DESTDIR/var/lib/keydb"; \
	mkdir -p "$KEYDB_DESTDIR/etc/keydb/conf.d"; \
	cp -v keydb.conf "$KEYDB_DESTDIR/etc/keydb/"; \
	touch "$KEYDB_DESTDIR/etc/keydb/users.acl"

RUN set -eux; \
	cd build/keydb-root; \
	scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" .  | awk '{print $3}' | xargs -r \
		strip \
			--remove-section=.comment \
			--remove-section=.note \
			-R .gnu.lto_* -R .gnu.debuglto_* \
			-N __gnu_lto_slim -N __gnu_lto_v1 \
			--strip-unneeded


FROM registry.conarx.tech/containers/alpine/edge


ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   "edge"
LABEL org.opencontainers.image.base.name "registry.conarx.tech/containers/alpine/edge"

# Copy in built binaries
COPY --from=builder /build/keydb-root /

RUN set -eux; \
	true "Dependencies"; \
	apk add --no-cache \
		libunwind \
		libuuid \
		openssl \
		curl; \
	true "User setup"; \
	addgroup -S keydb 2>/dev/null; \
	adduser -S -D -H -h /var/lib/keydb -s /sbin/nologin -G keydb -g keydb keydb; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*

# include /path/to/fragments/*.conf
RUN set -eux; \
	# Disable listening on only localhost
	sed -ire 's,^bind \(.*\),#bind\1,' /etc/keydb/keydb.conf; \
	grep -E '^#bind' /etc/keydb/keydb.conf; \
	# Set PID file
	sed -ire 's,^pidfile \(.*\),pidfile /run/keydb.pid,' /etc/keydb/keydb.conf; \
	grep -E '^pidfile /run/keydb.pid' /etc/keydb/keydb.conf; \
	# Set working dir
	sed -ire 's,^dir \(.*\),dir /var/lib/keydb/,' /etc/keydb/keydb.conf; \
	grep -E '^dir /var/lib/keydb/' /etc/keydb/keydb.conf; \
	# Set ACL file location
	sed -ire 's,^# \(aclfile /etc/keydb/users.acl\),\1,' /etc/keydb/keydb.conf; \
	grep -E '^aclfile /etc/keydb/users\.acl' /etc/keydb/keydb.conf; \
	# Disable protected mode by default
	sed -ire 's,^protected-mode yes,protected-mode no,' /etc/keydb/keydb.conf; \
	grep -E '^protected-mode no' /etc/keydb/keydb.conf; \
	# Remove temp config file
	rm -f /etc/keydb/keydb.confire; \
	# Setup blank include file to prevent fatal startup error when none are specified
	touch /etc/keydb/conf.d/00-default.conf

# KeyDB
COPY etc/supervisor/conf.d/keydb.conf /etc/supervisor/conf.d/keydb.conf
COPY usr/local/share/flexible-docker-containers/init.d/42-keydb.sh /usr/local/share/flexible-docker-containers/init.d
COPY usr/local/share/flexible-docker-containers/tests.d/42-keydb.sh /usr/local/share/flexible-docker-containers/tests.d
COPY usr/local/share/flexible-docker-containers/healthcheck.d/42-keydb.sh /usr/local/share/flexible-docker-containers/healthcheck.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Permissions"; \
	chown root:root \
		/etc/supervisor/conf.d/keydb.conf; \
	chmod 0644 \
		/etc/supervisor/conf.d/keydb.conf; \
	chown root:keydb \
		/etc/keydb \
		/etc/keydb/keydb.conf \
		/etc/keydb/conf.d \
		/var/lib/keydb; \
	chmod 0640 \
		/etc/keydb/keydb.conf; \
	chmod 0755 \
		/etc/keydb \
		/etc/keydb/conf.d; \
	chmod 0770 \
		/var/lib/keydb; \
	fdc set-perms

VOLUME ["/var/lib/keydb"]

EXPOSE 6379
