module Assimp

  class Plane < FFI::Struct
    layout :a, :ai_real,
           :b, :ai_real,
           :c, :ai_real,
           :d, :ai_real
  end

  class Ray < FFI::Struct
    layout :pos, Vector3D,
           :dir, Vector3D
  end

  class Color3D < FFI::Struct
    layout :r, :ai_real,
           :g, :ai_real,
           :b, :ai_real
  end

  class String < FFI::Struct
    MAXLEN = 1024
    layout :length, :size_t,
           :data, [:char, MAXLEN]
  end

  Return = enum( :return, [ :SUCCESS, :FAILURE, -1, :OUTOFMEMORY, -3 ] )

  Origin = enum( :origin, [ :SET, :CUR, :END ] )

  DefaultLogStream = bitmask( :default_log_screen, [
    :FILE,
    :STDOUT,
    :STDERR,
    :DEBUGGER
  ])

  class MemoryInfo < FFI::Struct
    layout :textures, :uint,
           :materials, :uint,
           :meshes, :uint,
           :nodes, :uint,
           :animations, :uint,
           :cameras, :uint,
           :lights, :uint,
           :total, :uint
  end

end
