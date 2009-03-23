# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ropenlaszlo}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Oliver Steele"]
  s.date = %q{2009-03-23}
  s.description = %q{ROpenLaszlo is an interface to the OpenLaszlo compiler.}
  s.email = %q{steele@osteele.com}
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE", "CHANGES.rdoc", "TODO.rdoc"]
  s.files = ["lib/openlaszlo", "lib/openlaszlo/applet.rb", "lib/openlaszlo/compiler.rb", "lib/openlaszlo/compiler.rb.orig", "lib/openlaszlo.rb", "lib/ropenlaszlo.rb", "lib/tasks", "lib/tasks/openlaszlo.rake", "test/compilation-error.lzx", "test/compilation-warning.lzx", "test/compiler_test.rb", "test/tasks", "test/tasks/Rakefile", "test/tasks/test.lzx", "test/tasks/test.swf", "test/test.lzx", "test/test_utils.rb", "README.rdoc", "MIT-LICENSE", "CHANGES.rdoc", "TODO.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/osteele/ropenlaszlo}
  s.rdoc_options = ["--title", "ROpenLaszlo: Ruby interface to the OpenLaszlo compiler", "--exclude", "test/.*", "--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ropenlaszlo}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby interface to the OpenLaszlo compiler.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
