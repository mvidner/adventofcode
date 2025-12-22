all: .ruby

.ruby:
	@echo; echo Ruby
	if test -d ruby/spec; then cd ruby; rspec; fi
	test -f sample.txt && ruby ruby/solution.rb sample.txt
	test -f sample2.txt && ruby ruby/solution.rb sample2.txt
	ruby ruby/solution.rb
