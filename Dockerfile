FROM ubuntu:bionic
LABEL maintainer="Lee Jones <lee.jones@linaro.org> (@lag-linaro)"

# Install 'tzdata' seperately to avoid forced user interaction
RUN set -x								&& \
	apt update							&& \
	apt install -y --no-install-recommends	\
	    	tzdata

# Install pre-requisites
RUN set -x								&& \
	apt update							&& \
	apt install -y --no-install-recommends	\
		build-essential			\
		pkg-config			\
		git				\
		ca-certificates			\
		devscripts			\
		debhelper			\
		libffi-dev			\
		libnspr4-dev			\
		wget				\
		zip				\
		pkg-kde-tools			\
		python				\
		python-pip			\
		python-sphinx			\
		erlang				\
		erlang-reltool			\
		libicu-dev			\
		libcurl4-openssl-dev		\
		npm		

# Install the Sphinx RTC Theme package
RUN pip install sphinx_rtd_theme

# Create and `cd` into build directory
ENV BUILDDIR couchdb-build
RUN mkdir ${BUILDDIR}

# Pull and configure CouchDB
RUN set -x								&& \
	cd ${BUILDDIR}							&& \
	git clone https://github.com/apache/couchdb.git			&& \
	cd couchdb 							&& \
	./configure -c 							&& \
	mv bin/rebar bin/rebar-orig					&& \
	wget https://github.com/rebar/rebar/wiki/rebar -O bin/rebar     && \
	chmod +x bin/rebar                                              && \
	cd ..

# Pull CouchDB Packaging and build/install Spider Monkey dependency
RUN set -x								&& \
	cd ${BUILDDIR}							&& \
	git clone https://github.com/apache/couchdb-pkg.git		&& \
	cd couchdb-pkg							&& \
	make couch-js-debs						&& \
	dpkg -i js/couch-libmozjs185-*.deb				&& \
	make build-couch $(lsb_release -cs) PLATFORM=$(lsb_release -cs)
