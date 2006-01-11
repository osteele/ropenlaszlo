require 'openlaszlo'

rule '.swf' => '.lzx' do |t|
  puts "Compiling #{t.source} => #{t.name}" if verbose
  OpenLaszlo::compile t.source, :output => t.name
end
