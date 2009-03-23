# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# All rights reserved.
# 
# This program is free software.
# This file is distributed under an MIT style license.  See
# MIT-LICENSE for details.

require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'

PKG_NAME = "ropenlaszlo"
RUBYFORGE_PROJECT = 'ropenlaszlo'

DOC_FILES = FileList['README.rdoc', 'MIT-LICENSE', 'CHANGES.rdoc', 'TODO.rdoc']
PKG_FILES = FileList['{lib,test}/**/*'].exclude('.svn') + DOC_FILES

CLEAN.include FileList['test/*.swf']

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = PKG_NAME
    s.rubyforge_project = RUBYFORGE_PROJECT
    s.files = PKG_FILES
    s.summary = "Ruby interface to the OpenLaszlo compiler."
    s.homepage = 'http://github.com/osteele/ropenlaszlo'
    s.author = 'Oliver Steele'
    s.email = 'steele@osteele.com'
    s.require_path = 'lib'
    s.description = <<-EOF
    ROpenLaszlo is an interface to the OpenLaszlo compiler.
EOF
    s.has_rdoc = true
    s.extra_rdoc_files = DOC_FILES
    s.rdoc_options << '--title' << "ROpenLaszlo: #{s.summary.sub(/.$/,'')}" <<
      '--exclude' << 'test/.*'
    '--main' << 'README.rdoc'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'rdoc'
  #rd.options += spec.rdoc_options.to_a.flatten
  rd.rdoc_files.include 'doc/README' # neceessary for --main to work
  rd.rdoc_files.include FileList['lib/**/*.rb']
  rd.rdoc_files.exclude 'test/*'
end

desc 'Uninstall and reinstall the gem, for local testing.'
task :reinstall do
  sh "gem uninstall ropenlaszlo"
  sh "gem install pkg/ropenlaszlo"
end

task :clean do
  rm_rf 'pkg'
end

task :publish_rdoc => :rdoc do
  sh" scp -r rdoc/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}"
end

# Adapted from Typo's Rakefile
desc "Publish the release files to RubyForge."
task :tag_svn do
  url = `svn info`[/^URL:\s*(.*\/)trunk/, 1]
  system("svn cp #{url}/trunk #{url}/tags/release_#{PKG_VERSION.gsub(/\./,'_')} -m 'tag release #{PKG_VERSION}'")
end
