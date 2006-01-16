# Author:: Oliver Steele
# Copyright:: Copyright (c) 2005-2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.
#
# This module contains utility methods for compiling OpenLaszlo[http://openlaszlo.org] programs.  See the OpenLaszlo module documentation for usage information.
# 
#--
# Bugs:
# - syntax error compiles swf anyway
#
# Todo:
# - unit tests
# - doc :profile
#
# Wishlist:
# - compile_string
# - detect compiler version
# - select compiler based on file location; or, copy files
# - retrieve dependencies
# - retrieve compiler warnings
#
# Corners:
# - detect invalid parameters
# - server isn't running
# - lps-dev/foo isn't inside lps

 
# == module OpenLaszlo
# 
# This module contains utility methods for compiling OpenLaszlo[http://openlaszlo.org] programs.
#
# Example:
#   # Set up the environment to use the compile server.  The OpenLaszlo server
#   # must be running in order at this location in order for this to work.
#   ENV['OPENLASZLO_HOME'] = '/Applications/OpenLaszlo Server 3.1'
#   ENV['OPENLASZLO_URL'] = 'http://localhost:8080/lps-3.1'
#
#   require 'openlaszlo'
#   # Create a file 'hello.swf' in the current directory:
#   OpenLaszlo::compile 'hello.lzx'
#
# See OpenLaszlo.compile for additional documentation.
# 
module OpenLaszlo
  # This class implements a bridge to the compile server.
  #
  # If you don't need multiple compilers, you can use the methods in
  # the OpenLaszlo module instead.
  #
  # The compile server is faster than CommandLineCompiler, but can only compile
  # files in the same directory as the {OpenLaszlo SDK}[http://openlaszlo.org].
  class CompileServer
    # Options:
    # * <tt>:openlaszlo_home</tt> - filesystem location of the OpenLaszlo SDK.  Defaults to EVN['OPENLASZLO_HOME']
    # * <tt>:server_uri</tt> - the URI of the server.  Defaults to ENV['OPENLASZLO_URL'] if this is specified, otherwise to 'http://localhost:8080/lps-dev'.
    def initialize params={}
      @home = params[:home] || ENV['OPENLASZLO_HOME']
      @base_url = params[:server_uri] || ENV['OPENLASZLO_URL'] || 'http://localhost:8080/lps-dev'
    end
    
    # Invokes the OpenLaszlo server-based compiler on +source_file+.
    # +source_file+ must be inside the home directory of the server.
    # See OpenLaszlo.compile for a description of the +params+.
    #
    # Additional options:
    # * <tt>:format</tt> - request type (default 'swf')
    def compile source_file, params={}
      require 'net/http'
      require 'uri'
      # assert that pathname is relative to LPS home:
      absolute_path = File.expand_path source_file
      raise "#{absolute_path} isn't inside #{@home}" unless absolute_path.index(@home) == 0
      server_relative_path = absolute_path[@home.length..-1]
      # FIXME: this doesn't handle quoting; use recursive File.split instead
      # FIXME: should encode the url, for filenames that include '/'
      server_relative_path.gsub(File::Separator, '/')
      output = params[:output] || "#{File.basename source_file, '.lzx'}.swf"
      options = {
        :lzr => params[:runtime],
        :debug => params[:debug],
        :lzproxied => params[:proxied] == nil ? params[:proxied] : false,
        :lzt => params[:format] || 'swf'}
      query = options.map{|k,v|"#{k}=#{v}" unless v.nil?}.compact.join('&')
      url = "#{@base_url}#{server_relative_path}"
      url += "?#{query}" unless query.empty?
      Net::HTTP.get_response URI.parse(url) do |response|
        case response
        when Net::HTTPOK
          File.open(output, 'w') do |f|
            response.read_body do |segment|
              f << segment
            end
          end
        else
          response.value # raises error
        end
      end
      return output
    end
  end
  
  # This class implements a bridge to the command-line compiler.
  #
  # If you don't need multiple compilers, you can use the methods in
  # the OpenLaszlo module instead.
  #
  # The command-line compiler is slower than CompileServer, but,
  # unlike the server, it can compile files in any location.
  class CommandLineCompiler
    # Creates a new compiler.
    #
    # Options are:
    # * <tt>:compiler_script</tt> - the path to the shell script that
    # invokes the compiler.  This defaults to a standard location inside
    # the value specified by :home.
    # * <tt>:openlaszlo_home</tt> - the home directory of the OpenLaszlo SDK.
    # This defaults to ENV['OPENLASZLO_HOME'].
    def initialize params={}
      @lzc = params[:compiler_script]
      unless @lzc
        home = params[:openlaszlo_home] || ENV['OPENLASZLO_HOME']
        raise ":compiler_script or :openlaszlo_home must be specified" unless home
        search = lzc_directories.map{|f| File.join(home, f, 'lzc')}
        found = search.select{|f| File.exists? f}
        raise "couldn't find bin/lzc in #{search.join(' or ')}" if found.empty?
        @lzc = found.first
        # Adjust the name for Windows
        @lzc += '.bat' if windows?
      end
    end
    
    # Invokes the OpenLaszlo command-line compiler on +source_file+.
    #
    # See OpenLaszlo.compile for a description of the +params+.
    def compile source_file, params={}
      default_output = File.basename(source_file, '.lzx') + '.swf'
      output = params[:output] || default_output
      # TODO: could handle this case by compiling to a temporary directory and
      # renaming from there
      raise "#{source_file} and #{output} do not have the same basename." unless File.basename(source_file, '.lzx') == File.basename(output, '.swf')
      args = []
      args << '--runtime=#{params[:runtime]}' if params[:runtime]
      args << '--debug' if params[:debug]
      args << '--profile' if params[:profile]
      args << "--dir '#{File.dirname output}'" unless File.dirname(source_file) == File.dirname(output)
      args << source_file
      `#{@lzc} #{args.join(' ')}`
    end
    
    private
    
    # Locations in which to look for the lzc script, relative to OPENLASZLO_HOME
    def lzc_directories
      [# binary distro location
        'bin',
        # binary distro location
        'WEB-INF/lps/server/bin'
      ]
    end
    
    def windows?
      RUBY_PLATFORM =~ /win/ and not RUBY_PLATFORM =~ /darwin/
    end
  end
  
  # Returns the default compiler.  Use the server-based compiler if it's
  # available, since it's so much faster.
  def self.compiler
    return @compiler if @compiler
    return @compiler = CompileServer.new if ENV['OPENLASZLO_URL'] and ENV['OPENLASZLO_HOME']
    return @compiler = CommandLineCompiler.new if ENV['OPENLASZLO_HOME']
    raise <<EOF
Couldn\'t find an OpenLaszlo compiler.

To use the compile server (recommended), set ENV['OPENLASZLO_URL'] and ENV['OPENLASZLO_HOME'].

To use the command-line compiler, set ENV['OPENLASZLO_HOME'].
EOF
  end
  
  # Sets the default compiler for future invocations of OpenLaszlo.compile.
  def self.compiler= compiler
    @compiler = compiler
  end
  
  # Compile an OpenLaszlo[http://openlaszlo.org] source file.
  #
  # Examples:
  #   require 'openlaszlo'
  #   OpenLaszlo::compile 'hello.lzx'
  #   OpenLaszlo::compile 'hello.lzx', :debug => true
  #   OpenLaszlo::compile 'hello.lzx', :runtime => 'swf8'
  #   OpenLaszlo::compile 'hello.lzx', {:runtime => 'swf8', :debug => true}
  #   OpenLaszlo::compile 'hello.lzx', :output => 'hello-world.swf' # server only
  #
  # Options are:
  # * <tt>:debug</tt> - debug mode (default false)
  # * <tt>:output</tt> - specify the name and location for the output file (default = input_file.sub(/\.lzx$/, '.swf'))
  # * <tt>:proxied</tt> - is application proxied (default true)
  # * <tt>:runtime</tt> - runtime (default swf7)
  #
  # See CompileServer.compile and CommandLineCompiler.compile for additional options
  # that are specific to these compilers.
  def self.compile source_file, params={}
    compiler.compile source_file, params
  end
  
  def self.make_html source_file, params={} #:nodoc:
    raise 'not really supported, for now'
    params = {
      :format => 'html-object',
      :output => File.basename(source_file, '.lzx')+'.html'}.update(params)
    compiler.compile source_file, params
    source_file = params[:output]
    s = open(source_file).read
    open(source_file, 'w') {|f| f.write s.gsub!(/\.lzx\?lzt=swf&amp;/, '.lzx.swf?')}
  end
end
