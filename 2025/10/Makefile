all: .ruby .python

.ruby:
	@echo; echo Ruby
	if test -d ruby/spec; then cd ruby; rspec; fi
	test -f sample.txt && ruby ruby/solution.rb sample.txt
	ruby ruby/solution.rb

.python:
	@echo; echo Python
	test -f sample.txt && python/solution.py sample.txt && echo
	python/solution.py
