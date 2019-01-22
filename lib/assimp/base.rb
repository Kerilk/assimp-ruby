module Assimp
  extend FFI::Library
  ffi_lib 'assimp'

  class String < FFI::Struct
  end

  module StructAccessors
    def struct_attr_reader(*args)
      args.each { |attr|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        if @layout[attr].type.kind_of?( FFI::StructByValue ) && @layout[attr].type.struct_class == Assimp::String
          define_method(attr) { self[attr].data }
        else
          define_method(attr) { self[attr] }
        end
      }
    end

    def struct_attr_writer(*args)
      args.each { |attr|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        if @layout[attr].type.kind_of?( FFI::StructByValue ) && @layout[attr].type.struct_class == Assimp::String
          define_method(attr.to_s+"=") { |o| self[attr].data = o }
        else
          define_method(attr.to_s+"=") { |o| self[attr] = o }
        end
      }
    end

    def struct_attr_accessor(*args)
      struct_attr_reader(*args)
      struct_attr_writer(*args)
    end

    def struct_array_attr_reader(*args)
      args.each { |attr, klass, count|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        t = nil
        s = nil
        if klass.kind_of? Symbol
          t = Assimp::find_type(klass)
          s = t.size
          define_method(attr) do
            n = ( count ? self[count] : self[:"num_#{attr}"] )
            p = self[attr]
            if n == 0 || p.null?
              []
            else
              n.times.collect { |i|
                p.get(t, i*s) 
              }
            end
          end
        elsif klass.kind_of?(Class) && klass < FFI::Struct
          s = klass.size
          define_method(attr) do
            n = ( count ? self[count] : self[:"num_#{attr}"] )
            p = self[attr]
            if n == 0 || p.null?
              []
            else
              n.times.collect { |i|
                klass.new(p+i*s)
              }
            end
          end
        else
          raise "Invalid type: #{klass.inspect} for #{attr.inspect}!"
        end
      }
    end

    def struct_ref_array_attr_reader(*args)
      args.each { |attr, klass, count|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        define_method(attr) do
          n = ( count ? self[count] : self[:"num_#{attr}"] )
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
