# Copyright (c) 2006 Oliver Steele <steele@osteele.com>
# All rights reserved.
# 
# This program is free software.
# This file is distributed under an MIT style license.  See
# MIT-LICENSE for details.

require 'rubygems'
require 'rake/gempackagetask'

PKG_VERSION = '0.2.0'
PKG_FILES = FileList['{lib,doc,test}/**/*'].exclude('.svn')

spec = Gem::Specification.new do |s|
  s.name = 'ropenlaszlo'
  s.version = PKG_VERSION
  s.summary = "Ruby interface to OpenLaszlo."
  s.author = 'Oliver Steele'
  s.email = 'steele@osteele.com'
  s.homepage = 'http://ropenlaszlo.rubyforge.org'
  s.rubyforge_project = 'ropenlaszlo'
  #s.requirements << 'none'
  s.require_path = 'lib'
  s.files = PKG_FILES
  s.description = <<-EOF
    ROpenLaszlo is an interface to the OpenLaszlo compiler.
EOF
  s.has_rdoc = true
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :install do
  sh "sudo gem install ropenlaszlo --source file://#{File.expand_path "pkg/ropenlaszlo-0.2.0.gem"}"
end

task :clean do
  rm_rf 'pkg'
end
