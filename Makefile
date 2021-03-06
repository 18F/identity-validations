# Makefile for building and running the project.
# The purpose of this Makefile is to avoid developers having to remember
# project-specific commands for building, running, etc.  Recipes longer
# than one or two lines should live in script files of their own in the
# bin/ directory.

all: check

setup:
	bin/setup

check: lint test

lint:
	@echo "--- rubocop ---"
	bundle exec rubocop

test:
	bundle exec rspec

.PHONY: setup all lint test check
