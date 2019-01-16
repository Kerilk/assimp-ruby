module Assimp

  class Matrix3x3 < FFI::Struct
    layout :a1, :ai_real, :a2, :ai_real, :a3, :ai_real,
           :b1, :ai_real, :b2, :ai_real, :b3, :ai_real,
           :c1, :ai_real, :c2, :ai_real, :c3, :ai_real
  end

end
