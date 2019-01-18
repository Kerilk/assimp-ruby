module Assimp

  class Matrix4x4 < FFI::Struct
    extend StructAccessors
    layout :a1, :ai_real, :a2, :ai_real, :a3, :ai_real, :a4, :ai_real,
           :b1, :ai_real, :b2, :ai_real, :b3, :ai_real, :b4, :ai_real,
           :c1, :ai_real, :c2, :ai_real, :c3, :ai_real, :c4, :ai_real,
           :d1, :ai_real, :d2, :ai_real, :d3, :ai_real, :d4, :ai_real
    struct_attr_reader :a1, :a2, :a3, :a4,
                       :b1, :b2, :b3, :b4,
                       :c1, :c2, :c3, :c4,
                       :d1, :d2, :d3, :d4

    def to_s
      <<EOF
< <#{a1}, #{a2}, #{a3}, #{a4}>,
  <#{b1}, #{b2}, #{b3}, #{b4}>,
  <#{c1}, #{c2}, #{c3}, #{c4}>,
  <#{d1}, #{d2}, #{d3}, #{d4}> >
EOF
    end
  end

end
