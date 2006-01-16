# Author:: Oliver Steele
# Copyright:: Copyright (c) 2005-2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

$:.unshift File.dirname(__FILE__) + "/../lib"
require 'utils'
require 'test/unit'
require 'ropenlaszlo'
require 'fileutils'

include FileUtils

REQUIRED_ENV_VALUES = %w{OPENLASZLO_HOME OPENLASZLO_HOME}
unless REQUIRED_ENV_VALUES.reject {|w| ENV[w]}.empty?
  raise "These environment variables must be set: #{REQUIRED_ENV_VALUES}.join(', ')"
end

module CompilerTestHelper
  def super_setup
    OpenLaszlo::compiler = nil
    #cd File.expand_path(File.dirname(__FILE__))
  end
  
  private
  def testfile_pathname file
    File.expand_path file, File.dirname(__FILE__)
  end
  
  def compile file, output=nil, options={}
    file = testfile_pathname file
    output = File.basename(file, '.lzx')+'.swf'
    rm_f output
    begin
      OpenLaszlo::compile file, *options
      assert File.exists?(output), "#{output} does not exist"
    ensure
      rm_f output
    end
  end
end

class CompileServerTest < Test::Unit::TestCase
  include CompilerTestHelper
  
  def setup
    @test_dir = File.join(ENV['OPENLASZLO_HOME'], 'ropenlaszlo-tests')
    mkdir @test_dir
    super_setup
  end
  
  def teardown
    rm_rf @test_dir
  end
    
  def test_compilation
    compile 'test.lzx'
  end
  
  private
  alias :saved_compile :compile
  
  def compile file, output=nil, options={}
    file = testfile_pathname file
    server_local_file = File.join @test_dir, File.basename(file)
    cp file, server_local_file
    begin
      saved_compile server_local_file, output, options
    ensure
      rm_f server_local_file
    end
  end
end

class CommandLineCompilerTest < Test::Unit::TestCase
  include CompilerTestHelper
  
  def setup
    super_setup
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
    callcc do |continue| @teardown.call(continue) end
  end
  
  def test_compilation
    compile 'test.lzx'
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
