# Author:: Oliver Steele
# Copyright:: Copyright (c) 2005-2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
require 'ropenlaszlo'
require 'fileutils'

include FileUtils

REQUIRED_ENV_VALUES = %w{OPENLASZLO_HOME OPENLASZLO_HOME}
unless REQUIRED_ENV_VALUES.reject {|w| ENV[w]}.empty?
  raise "These environment variables must be set: #{REQUIRED_ENV_VALUES}.join(', ')"
end

class << ENV
  # Execute a block, restoring the bindings for +keys+ at the end.
  # NOT thread-safe!
  def with_saved_bindings keys, &block
    saved_bindings = Hash[*keys.map {|k| [k, ENV[k]]}.flatten]
    begin
      block.call
    ensure
      ENV.update saved_bindings
    end
  end
  
  # Execute a block with the temporary bindings in +bindings+.
  # Doesn't remove keys; simply sets them to nil.
  def with_bindings bindings, &block
    with_saved_bindings bindings.keys do
      ENV.update bindings
      return block.call
    end
  end
end

module CompilerTestHelper
  def super_setup
    OpenLaszlo::compiler = nil
    cd File.dirname(__FILE__)
  end
  
  private
  def compile file, output=nil, options={}
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
    bindings = {'OPENLASZLO_URL' => nil}
    @saved_bindings = Hash[*bindings.keys.map{|k|[k,ENV[k]]}.flatten]
    ENV.update bindings
    super_setup
  end
  
  def teardown
    ENV.update @saved_bindings
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
