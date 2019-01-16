module Assimp

  class Quaternion < FFI::Struct
    layout :w, :ai_real,
           :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real
  end

end
