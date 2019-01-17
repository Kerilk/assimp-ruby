module Assimp
  extend FFI::Library
  ffi_lib 'assimp'

  module StructAccessors
    def struct_attr_reader(*args)
      args.each { |attr|
        define_method(attr) { self[attr] }
      }
    end

    def struct_array_attr_reader(*args)
      args.each { |attr, klass|
        define_method(attr) do
          n = self[:"num_#{attr}"]
          p = self[attr]
          if n == 0 || p.null?
            []
          else
            ptrs = p.read_array_of_pointer(self[:"num_#{attr}"])
            ptrs.collect { |ptr| ptr.null? ? nil : klass::new(ptr) }
          end
        end
      }
    end
  end

end
