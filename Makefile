PACKAGE ?= ranch_test
VERSION ?= $(shell git describe --tags)
BASE_DIR ?= $(shell pwd)
ERLANG_BIN ?= $(shell dirname $(shell which erl))
REBAR ?= $(shell pwd)/rebar3
MAKE = make

.PHONY: compile rel clean packageclean check lint shell

all: compile

compile:
	$(REBAR) compile

rel: compile
	$(REBAR) release

run: rel
	./_build/default/rel/ranch_test/bin/env start
	sleep 2
	./_build/default/rel/ranch_test/bin/env ping

ping:
	./_build/default/rel/ranch_test/bin/env ping

attach:
	./_build/default/rel/ranch_test/bin/env attach

stop:
	./_build/default/rel/ranch_test/bin/env stop

clean: packageclean
	$(REBAR) clean

packageclean:
	rm -fr *.deb
	rm -fr *.tar.gz

check: xref dialyzer lint

lint:
	$(REBAR) as lint lint

shell:
	$(REBAR) shell --apps ranch_test

include tools.mk

