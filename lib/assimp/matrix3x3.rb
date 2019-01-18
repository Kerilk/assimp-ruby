module Assimp

  class Matrix3x3 < FFI::Struct
    extend StructAccessors
    layout :a1, :ai_real, :a2, :ai_real, :a3, :ai_real,
           :b1, :ai_real, :b2, :ai_real, :b3, :ai_real,
           :c1, :ai_real, :c2, :ai_real, :c3, :ai_real
    struct_attr_reader :a1, :a2, :a3,
                       :b1, :b2, :b3,
                       :c1, :c2, :c3

    def to_s
      <<EOF
< <#{a1}, #{a2}, #{a3}>,
  <#{b1}, #{b2}, #{b3}>,
  <#{c1}, #{c2}, #{c3}> >
EOF
    end
  end

end
