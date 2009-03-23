# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# All rights reserved.
# 
# This program is free software.
# This file is distributed under an MIT style license.  See
# MIT-LICENSE for details.

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'

PKG_NAME = "ropenlaszlo"
PKG_VERSION = '0.4.1'
RUBYFORGE_PROJECT = 'ropenlaszlo'
RUBYFORGE_USER = ENV['RUBYFORGE_USER']

PKG_FILES = FileList['{lib,doc,test}/**/*'].exclude('.svn')

CLEAN.include FileList['test/*.swf']

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
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
  s.extra_rdoc_files = FileList['doc/*']
  s.rdoc_options << '--title' << "ROpenLaszlo: #{s.summary.sub(/.$/,'')}" <<
    '--exclude' << 'test/.*'
    '--main' << 'doc/README'
end

gemtask = Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :gemspec => :gem do
  cp "pkg/#{gemtask.gem_file}", "#{spec.name}.gemspec"
end

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.options += spec.rdoc_options.to_a.flatten
  rd.rdoc_files.include 'doc/README' # neceessary for --main to work
  rd.rdoc_files.include spec.files-['doc/README']
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
