$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'ropenlaszlo'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'test_utils.rb')

include FileUtils

REQUIRED_ENV_VALUES = %w{OPENLASZLO_HOME OPENLASZLO_HOME}
unless REQUIRED_ENV_VALUES.reject {|w| ENV[w]}.empty?
  raise "These environment variables must be set: #{REQUIRED_ENV_VALUES}.join(', ')"
end

module CompilerTestHelper
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
  
  private
  def testfile_pathname(file)
    return File.expand_path(file, File.dirname(__FILE__))
  end
  
  def assert_same_file(a, b)
    assert_equal File.expand_path(a), File.expand_path(b)
  end
  
  def compile(file, output=nil, options={})
    file = testfile_pathname(file)
    output ||= File.join(File.dirname(file), File.basename(file, '.lzx')+'.lzr=swf8.swf')
    rm_f output
    raise "Unable to remove output file: #{output}" if File.exists?(output)
    begin
      result = OpenLaszlo::compile(file, *options)
      assert_same_file output, result[:output]
      assert File.exists?(output), "#{output} does not exist"
      return result
    ensure
      rm_f output
    end
  end
  
  # Tests that are shared between CompilerServerTest and
  # CommandLineCompilerTest.
  module InstanceMethods
    def test_compilation
      result = compile 'test.lzx'
    end
    
    def test_compilation_warning
      result = compile 'compilation-warning.lzx'
      assert_instance_of Array, result[:warnings]
      assert_equal 1, result[:warnings].length
      assert_match /^compilation-warning.lzx:1:36/, result[:warnings].first
    end
    
    def test_compilation_error
      ex = (compile 'compilation-error.lzx' rescue $!)
      assert_instance_of OpenLaszlo::CompilationError, ex
      assert_match /^compilation-error.lzx:3:1: XML document structures must start and end within the same entity\./, ex.message
    end
  end
end

class CompileServerTest < Test::Unit::TestCase
  include CompilerTestHelper
  
  def setup
    OpenLaszlo::compiler = nil
    home = ENV['OPENLASZLO_HOME']
    dirs = Dir[File.join(home, 'Server', 'lps-*', 'WEB-INF')]
    home = File.dirname(dirs.first) if dirs.any?
    @test_dir = File.join(home, 'tmp/ropenlaszlo-tests')
    mkdir_p @test_dir
  end
  
  def teardown
    OpenLaszlo::compiler = nil
    rm_rf @test_dir
  end
  
  private
  alias :saved_compile :compile
  
  def compile(file, output=nil, options={})
    raise "unimplemented" if output
    file = testfile_pathname file
    server_local_file = File.join(@test_dir, File.basename(file))
    cp file, server_local_file
    begin
      saved_compile(server_local_file, output, options)
    ensure
      rm_f server_local_file
    end
  end
end

class CommandLineCompilerTest < Test::Unit::TestCase
  include CompilerTestHelper
  
  def setup
    OpenLaszlo::compiler = nil
    callcc do |exit|
      resume = nil
      ENV.with_bindings 'OPENLASZLO_URL' => nil do
        resume = callcc do |continue|
          @teardown = continue
          exit.call
        end
      end
      resume.call
    end
  end
  
  def teardown
    OpenLaszlo::compiler = nil
    callcc do |continue| @teardown.call(continue) end
  end
end

class CompilerFacadeTest < Test::Unit::TestCase
  def setup
    raise "ENV['OPENLASZLO_URL'] must be set" unless ENV['OPENLASZLO_URL']
    raise "ENV['OPENLASZLO_HOME'] must be set" unless ENV['OPENLASZLO_HOME']
    OpenLaszlo::compiler = nil
  end
  
  def test_select_server
    assert_instance_of OpenLaszlo::CompileServer, OpenLaszlo::compiler
  end
  
  def test_select_commandline
    ENV.with_bindings 'OPENLASZLO_URL' => nil do
      assert_instance_of OpenLaszlo::CommandLineCompiler, OpenLaszlo::compiler
    end
  end
  
  def test_missing_home
    ENV.with_bindings 'OPENLASZLO_HOME' => nil do
      assert_raise(RuntimeError) do OpenLaszlo::compiler end
    end
  end
end
