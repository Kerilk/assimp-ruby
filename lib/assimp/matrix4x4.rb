module Assimp

  class Matrix4x4 < FFI::Struct
    layout :a1, :ai_real, :a2, :ai_real, :a3, :ai_real, :a4, :ai_real,
           :b1, :ai_real, :b2, :ai_real, :b3, :ai_real, :b4, :ai_real,
           :c1, :ai_real, :c2, :ai_real, :c3, :ai_real, :c4, :ai_real,
           :d1, :ai_real, :d2, :ai_real, :d3, :ai_real, :d4, :ai_real
  end

end
