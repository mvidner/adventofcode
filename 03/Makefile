all: rust ruby

rust: solution
	@echo Rust
	./solution < input

ruby:
	@echo Ruby
	ruby solution.rb
	ruby extra.rb

solution: solution.rs
	rustc $^
