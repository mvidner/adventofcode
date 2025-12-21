all: .ruby

.ruby:
	@echo; echo Ruby
	if test -d ruby/spec; then cd ruby; rspec; fi
	test -f sample.txt && ruby ruby/solution.rb sample.txt
	ruby ruby/solution.rb
