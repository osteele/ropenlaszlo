# Author:: Oliver Steele
# Copyright:: Copyright (c) 2005-2006 Oliver Steele.  All rights reserved.
# License:: Ruby License.

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
