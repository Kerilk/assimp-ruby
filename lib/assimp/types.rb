module Assimp

  class Plane < FFI::Struct
    extend StructAccessors
    layout :a, :ai_real,
           :b, :ai_real,
           :c, :ai_real,
           :d, :ai_real
    struct_attr_reader :a, :b, :c, :d
    def to_s
      "(#{a}, #{b}, #{c}, #{d})"
    end
  end

  class Ray < FFI::Struct
    extend StructAccessors
    layout :pos, Vector3D,
           :dir, Vector3D
    struct_attr_reader :pos, :dir

    def to_s
      "|#{pos}, #{dir}|"
    end
  end

  class Color3D < FFI::Struct
    extend StructAccessors
    layout :r, :ai_real,
           :g, :ai_real,
           :b, :ai_real
    struct_attr_reader :r, :g, :b

    def to_s
      "[#{r}, #{g}, #{b}]"
    end
  end

  class String < FFI::Struct
    extend StructAccessors
    MAXLEN = 1024
    layout :length, :size_t,
           :data, [:char, MAXLEN]
    struct_attr_reader :length

    def data
      self[:data].to_a[0...length].pack("U*")
    end

    def to_s
      data
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
