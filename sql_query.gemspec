# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sql_query"
  spec.version       = "0.3.0"
  spec.authors       = ["sufleR"]
  spec.email         = ["szymon.fracczak@gmail.com"]
  spec.summary       = %q{Ruby gem to load and execute SQL queries from `.sql.erb` templates}
  spec.description   = %q{
    It makes working with pure SQL easier with syntax highlighting.
    Let's you clean your Ruby code from SQL strings.
  }
  spec.homepage      = "https://github.com/sufleR/sql_query"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", ">= 3.2"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pg", "~> 0.18"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "with_model", "~> 1.2"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
  spec.add_development_dependency "appraisal"
end
