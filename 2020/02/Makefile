all: .ruby .python

.ruby:
	@echo Ruby
	if test -d ruby/spec; then cd ruby; rspec; fi
	ruby ruby/solution.rb

.python:
	@echo Python
	if test -x python/solution_test.py; then python/solution_test.py; fi
	python/solution.py
