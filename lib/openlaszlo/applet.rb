# Author:: Oliver Steele
# Copyright:: Copyright (c) 2005-2008 Oliver Steele.  All rights reserved.
# License:: MIT License
module OpenLaszlo
  class Applet
    attr_reader :source

    def initialize(source)
      source = source + '.lzx' unless source =~ /\.lzx$/
      @source = source
    end

    def source_dir
      File.dirname(source)
    end

    def compile(target=nil, options={})
      target ||= source + '.swf'
      return if up2date?(target) unless options[:force]

      puts "Compiling #{source} -> #{target}" if options[:verbose]
      OpenLaszlo::compile(source, options)
    end

    def up2date?(target=nil)
      target ||= source + '.swf'
      return false unless File.exists?(target)
      sources = Dir["#{source_dir}/**/*"].reject { |fname| fname =~ /\.lzx\.swf/ } -
        Dir["#{source_dir}/build/**/*"]
      source_mtime = sources.
        # the 'rescue' ignores symbolic links without targets
        map { |f| File.mtime(f) rescue nil }.
        compact.
        max
      source_mtime < File.mtime(target)
    end

    def runtime_assets
      dir = File.dirname(source)
      includes = `grep -h http: #{dir}/*.lzx`.scan(/http:(.*?)['"]/).
        map(&:first)
      includes += `grep -h http: #{dir}/*/*.lzx`.scan(/http:(.*?)['"]/).
        map(&:first).
        map { |s| s.sub(/^\.\.\//, '') }
      return includes.
        uniq.
        map { |f| File.join(dir, f) }.
        select { |src| File.exists?(src) && File.ftype(src) != 'directory' }
    end

    def preprocess_to(dir, options={})
      files = Dir[File.join(source_dir, '**/*.js')] - Dir[File.join(source_dir, '.hg')]
      files.each do |src|
        dst = File.join(dir, src.sub(source_dir, ''))
        next if File.exists?(dst) and (!options[:force] and File.mtime(dst) > File.mtime(src))
        puts "Copy #{src} #{dst}"
        content = preprocess_string(open(src).read)
        open(dst, 'w') do |fo| fo << content end
      end.length
    end

    def preprocess_string(content)
      re = /^\s*([a-zA-Z][a-zA-Z0=9]*)\.each\(function\(([a-zA-Z][a-zA-Z0-9]*)\)\{(.*?)}\);/m
      content.gsub!(re) do |s|
        target, var, body = s.match(re).captures
        "var $0=#{target}, $1=$0.length;for(var $2=0; $1--;){var #{var}=$0[$2++];#{body}}"
      end
      return content
    end

    #
    # Class methods
    #

    def self.compile(basename, target, options={})
      source = "lzx/#{basename}"
      target = "public/#{target}"
      self.new(source).compile(target, options)
    end
  end
end
