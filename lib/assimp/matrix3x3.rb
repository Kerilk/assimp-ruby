module Assimp

  class Matrix3x3 < FFI::Struct
    extend StructAccessors
    layout :a1, :ai_real, :a2, :ai_real, :a3, :ai_real,
           :b1, :ai_real, :b2, :ai_real, :b3, :ai_real,
           :c1, :ai_real, :c2, :ai_real, :c3, :ai_real
    struct_attr_accessor :a1, :a2, :a3,
                         :b1, :b2, :b3,
                         :c1, :c2, :c3

    def self.identity
      m = Matrix3x3::new
      Assimp::identity_matrix3(m)
      m
    end

    def self.rotation(a, axis)
      # https://en.wikipedia.org/wiki/Rotation_matrix#Axis_and_angle
      c = Math::cos(a)
      s = Math::sin(a)
      t = 1 - c
      x = axis.x
      y = axis.y
      z = axis.z

      out = Matrix3x3
      out.a1 = t*x*x + c
      out.a2 = t*x*y - s*z
      out.a3 = t*x*z + s*y
      out.b1 = t*x*y + s*z
      out.b2 = t*y*y + c
      out.b3 = t*y*z - s*x
      out.c1 = t*x*z - s*y
      out.c2 = t*y*z + s*x
      out.c3 = t*z*z + c
      out
    end

    def to_s
      <<EOF
< <#{a1}, #{a2}, #{a3}>,
  <#{b1}, #{b2}, #{b3}>,
  <#{c1}, #{c2}, #{c3}> >
EOF
    end

    def quaternion
      q = Quaternion::new
      Assimp::create_quaternion_from_matrix(q, self)
    end

    def transpose!
      Assimp::transpose_matrix3(self)
      self
    end

    def transpose
      t = self.dup
      t.transpose!
    end

    def *(other)
      if other.kind_of?(Matrix3x3)
        m = self.dup
        Assimp::multiply_matrix3(m, other)
        m
      elsif other.kind_of?(Vector3D)
        v = other.dup
        Assimp::transform_vec_by_matrix3(v, self)
        v
      else
        "Unsupported operand: #{other.inspect}!"
      end
    end

    def determinant
      a1*b2*c3 - a1*b3*c2 + a2*b3*c1 - a2*b1*c3 + a3*b1*c2 - a3*b2*c1
    end

    def inverse
      det = determinant
      raise "Not inversible!" if det == 0.0
      m = Matrix3x3::new
      invdet = 1.0/det
      m.a1 = invdet  * (b2 * c3 - b3 * c2)
      m.a2 = -invdet * (a2 * c3 - a3 * c2)
      m.a3 = invdet  * (a2 * b3 - a3 * b2)
      m.b1 = -invdet * (b1 * c3 - b3 * c1)
      m.b2 = invdet  * (a1 * c3 - a3 * c1)
      m.b3 = -invdet * (a1 * b3 - a3 * b1)
      m.c1 = invdet  * (b1 * c2 - b2 * c1)
      m.c2 = -invdet * (a1 * c2 - a2 * c1)
      m.c3 = invdet  * (a1 * b2 - a2 * b1)
      m
    end

  end

end
