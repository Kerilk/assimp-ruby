module Assimp

  class Plane < FFI::Struct
    extend StructAccessors
    layout :a, :ai_real,
           :b, :ai_real,
           :c, :ai_real,
           :d, :ai_real
    struct_attr_accessor :a, :b, :c, :d
    def to_s
      "(#{a}, #{b}, #{c}, #{d})"
    end
  end

  class Ray < FFI::Struct
    extend StructAccessors
    layout :pos, Vector3D,
           :dir, Vector3D
    struct_attr_accessor :pos, :dir

    def to_s
      "|#{pos}, #{dir}|"
    end
  end

  class Color3D < FFI::Struct
    extend StructAccessors
    layout :r, :ai_real,
           :g, :ai_real,
           :b, :ai_real
    struct_attr_accessor :r, :g, :b

    def to_s
      "[#{r}, #{g}, #{b}]"
    end
  end

  if version >= Version::new(5,0,0)
    class String #< FFI::Struct
      extend StructAccessors
      MAXLEN = 1024
      layout :length, :ai_uint32,
             :data, [:char, MAXLEN]
      struct_attr_reader :length

      def data
        (pointer + 4).read_string(length)
      end

      def data=(str)
        sz = str.bytesize
        raise "String too long #{sz} > #{MAXLEN-1}!" if sz > MAXLEN-1
        self[:length] = sz
        (pointer + 4).write_string(str+"\x00")
      end

      def to_s
        data
      end
    end
  else
    class String #< FFI::Struct
      extend StructAccessors
      MAXLEN = 1024
      layout :length, :size_t,
             :data, [:char, MAXLEN]
      struct_attr_reader :length

      def data
        (pointer + Assimp.find_type(:size_t).size).read_string(length)
      end

      def data=(str)
        sz = str.bytesize
        raise "String too long #{sz} > #{MAXLEN-1}!" if sz > MAXLEN-1
        self[:length] = sz
        (pointer + Assimp.find_type(:size_t).size).write_string(str+"\x00")
      end

      def to_s
        data
      end
    end
  end

  Return = enum( :return, [ :SUCCESS, :FAILURE, -1, :OUTOFMEMORY, -3 ] )

  Origin = enum( :origin, [ :SET, :CUR, :END ] )

  DefaultLogStream = bitmask( :default_log_stream, [
    :FILE,
    :STDOUT,
    :STDERR,
    :DEBUGGER
  ])

  class MemoryInfo < FFI::Struct
    extend StructAccessors
    layout :textures, :uint,
           :materials, :uint,
           :meshes, :uint,
           :nodes, :uint,
           :animations, :uint,
           :cameras, :uint,
           :lights, :uint,
           :total, :uint
    struct_attr_reader :textures,
                       :materials,
                       :meshes,
                       :nodes,
                       :animations,
                       :cameras,
                       :lights,
                       :total
  end

end
