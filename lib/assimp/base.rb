module Assimp
  extend FFI::Library

  if ENV['ASSIMP_PATH']
    ffi_lib(ENV['ASSIMP_PATH'])
  else
    ffi_lib 'assimp'
  end

  class String < FFI::Struct
  end

  module StructAccessors

    def self.extended(mod)
      mod.instance_variable_set(:@__has_ref, false)
    end

    def has_ref?
      @__has_ref
    end

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
        elsif @layout[attr].type.kind_of?( FFI::StructByValue ) && @layout[attr].type.struct_class.has_ref?
          @__has_ref = true
          define_method(attr.to_s+"=") { |o| self.instance_variable_set(:"@#{attr}", o); self[attr] = o }
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

    def struct_array_attr_writer(*args)
      args.each { |attr, klass, count|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        @__has_ref = true
        t = nil
        s = nil
        if klass.kind_of? Symbol
          t = Assimp::find_type(klass)
          s = t.size
          define_method(:"#{attr}=") do |values|
            values = [] if values.nil?
            if count
              self[count] = values.length
            else
              self[:"num_#{attr}"] = values.length
            end
            ptr = (values.length == 0 ? nil : FFI::MemoryPointer::new(t, values.length))
            values.each_with_index { |v, i|
              ptr.put(t, i*s, v)
            }
            self.instance_variable_set(:"@#{attr}", ptr)
            self[attr] = ptr
            values
          end
        elsif klass.kind_of?(Class) && klass < FFI::Struct
          s = klass.size
          k = klass
          define_method(:"#{attr}=") do |values|
            values = [] if values.nil?
            if count
              self[count] = values.length
            else
              self[:"num_#{attr}"] = values.length
            end
            ptr = (values.length == 0 ? nil : FFI::MemoryPointer::new(klass, values.length))
            values.each_with_index { |v, i|
              ptr.put_array_of_uint8(i*s, v.pointer.read_array_of_uint8(s))
            }
            if k.has_ref?
              self.instance_variable_set(:"@#{attr}", [ptr, values])
            else
              self.instance_variable_set(:"@#{attr}", ptr)
            end
            self[attr] = ptr
            values
          end
        else
          raise "Invalid type: #{klass.inspect} for #{attr.inspect}!"
        end
      }
    end

    def struct_array_attr_checker(*args)
      args.each { |attr, klass, count|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        define_method(:"#{attr}?") do
          ! self[attr].null?
        end
      }
    end

    def struct_array_attr_accessor(*args)
      struct_array_attr_reader(*args)
      struct_array_attr_writer(*args)
      struct_array_attr_checker(*args)
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

    def struct_ref_array_attr_writer(*args)
      args.each { |attr, klass, count|
        raise "Invalid attribute #{attr.inspect}!" unless @layout.members.include?(attr)
        @__has_ref = true
        define_method(:"#{attr}=") do |values|
          values = [] if values.nil?
          if count
            self[count] = values.length
          else
            self[:"num_#{attr}"] = values.length
          end
          ptr = (values.length == 0 ? nil : FFI::MemoryPointer::new(:pointer, values.length))
          ptr.write_array_of_pointer(values.collect(&:pointer)) if ptr
          self.instance_variable_set(:"@#{attr}", [ptr, values.dup])
          self[attr] = ptr
          values
        end
      }
    end

    def struct_ref_array_attr_accessor(*args)
      struct_ref_array_attr_reader(*args)
      struct_ref_array_attr_writer(*args)
      struct_array_attr_checker(*args)
    end

  end

end
