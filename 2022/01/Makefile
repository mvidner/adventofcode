all: .ruby .python

.ruby:
	@echo; echo Ruby
	if test -d ruby/spec; then cd ruby; rspec; fi
	ruby ruby/solution.rb

.python:
	@echo; echo Python
	test -f sample.txt && python/solution.py sample.txt && echo
	python/solution.py
