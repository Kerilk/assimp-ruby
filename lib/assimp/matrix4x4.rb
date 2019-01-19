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

    def self.identity
      m = Matrix4x4::new
      Assimp::aiIdentityMatrix4(m)
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

      out = Matrix4x4
      out.a1 = t*x*x + c
      out.a2 = t*x*y - s*z
      out.a3 = t*x*z + s*y
      out.a4 = 0.0
      out.b1 = t*x*y + s*z
      out.b2 = t*y*y + c
      out.b3 = t*y*z - s*x
      out.b4 = 0.0
      out.c1 = t*x*z - s*y
      out.c2 = t*y*z + s*x
      out.c3 = t*z*z + c
      out.c4 = 0.0
      out.d1 = 0.0
      out.d2 = 0.0
      out.d3 = 0.0
      out.d4 = 1.0
      out
    end

    def self.translation(vec)
      out = identity
      out.a4 = vec.x
      out.b4 = vec.y
      out.c4 = vec.z
      out
    end

    def self.scaling(vec)
       out = identity
       out.a1 = v.x
       out.b2 = v.y
       out.c3 = v.z
       out
    end

    def to_s
      <<EOF
< <#{a1}, #{a2}, #{a3}, #{a4}>,
  <#{b1}, #{b2}, #{b3}, #{b4}>,
  <#{c1}, #{c2}, #{c3}, #{c4}>,
  <#{d1}, #{d2}, #{d3}, #{d4}> >
EOF
    end

    def decompose
      scaling = Vector3D::new
      rotation = Quaternion::new
      position = Vector3D::new
      Assimp::aiDecomposeMatrix(self, scaling, rotation, position)
      [scaling, rotation, position]
    end

    def transpose!
      Assimp::aiTransposeMatrix4(self)
      self
    end

    def transpose
      t = self.dup
      t.transpose!
    end

    def *(other)
      if other.kind_of?(Matrix4x4)
        m = self.dup
        Assimp::aiMultiplyMatrix4(m, other)
        m
      elsif other.kind_of?(Vector3D)
        v = other.dup
        Assimp::aiTransformVecByMatrix4(v, self)
        v
      else
        "Unsupported operand: #{other.inspect}!"
      end
    end

    def determinant
      a1*b2*c3*d4 - a1*b2*c4*d3 + a1*b3*c4*d2 - a1*b3*c2*d4 +
      a1*b4*c2*d3 - a1*b4*c3*d2 - a2*b3*c4*d1 + a2*b3*c1*d4 -
      a2*b4*c1*d3 + a2*b4*c3*d1 - a2*b1*c3*d4 + a2*b1*c4*d3 +
      a3*b4*c1*d2 - a3*b4*c2*d1 + a3*b1*c2*d4 - a3*b1*c4*d2 +
      a3*b2*c4*d1 - a3*b2*c1*d4 - a4*b1*c2*d3 + a4*b1*c3*d2 -
      a4*b2*c3*d1 + a4*b2*c1*d3 - a4*b3*c1*d2 + a4*b3*c2*d1
    end

    def inverse
      det = determinant
      raise "Not inversible!" if det == 0.0
      m = Matrix4x4::new
      invdet = 1.0/det
      m.a1 = invdet  * (b2 * (c3 * d4 - c4 * d3) +
                        b3 * (c4 * d2 - c2 * d4) +
                        b4 * (c2 * d3 - c3 * d2))
      m.a2 = -invdet * (a2 * (c3 * d4 - c4 * d3) +
                        a3 * (c4 * d2 - c2 * d4) +
                        a4 * (c2 * d3 - c3 * d2))
      m.a3 = invdet  * (a2 * (b3 * d4 - b4 * d3) +
                        a3 * (b4 * d2 - b2 * d4) +
                        a4 * (b2 * d3 - b3 * d2))
      m.a4 = -invdet * (a2 * (b3 * c4 - b4 * c3) +
                        a3 * (b4 * c2 - b2 * c4) +
                        a4 * (b2 * c3 - b3 * c2))
      m.b1 = -invdet * (b1 * (c3 * d4 - c4 * d3) +
                        b3 * (c4 * d1 - c1 * d4) +
                        b4 * (c1 * d3 - c3 * d1))
      m.b2 = invdet  * (a1 * (c3 * d4 - c4 * d3) +
                        a3 * (c4 * d1 - c1 * d4) +
                        a4 * (c1 * d3 - c3 * d1))
      m.b3 = -invdet * (a1 * (b3 * d4 - b4 * d3) +
                        a3 * (b4 * d1 - b1 * d4) +
                        a4 * (b1 * d3 - b3 * d1))
      m.b4 = invdet  * (a1 * (b3 * c4 - b4 * c3) +
                        a3 * (b4 * c1 - b1 * c4) +
                        a4 * (b1 * c3 - b3 * c1))
      m.c1 = invdet  * (b1 * (c2 * d4 - c4 * d2) +
                        b2 * (c4 * d1 - c1 * d4) +
                        b4 * (c1 * d2 - c2 * d1))
      m.c2 = -invdet * (a1 * (c2 * d4 - c4 * d2) +
                        a2 * (c4 * d1 - c1 * d4) +
                        a4 * (c1 * d2 - c2 * d1))
      m.c3 = invdet  * (a1 * (b2 * d4 - b4 * d2) +
                        a2 * (b4 * d1 - b1 * d4) +
                        a4 * (b1 * d2 - b2 * d1))
      m.c4 = -invdet * (a1 * (b2 * c4 - b4 * c2) +
                        a2 * (b4 * c1 - b1 * c4) +
                        a4 * (b1 * c2 - b2 * c1))
      m.d1 = -invdet * (b1 * (c2 * d3 - c3 * d2) +
                        b2 * (c3 * d1 - c1 * d3) +
                        b3 * (c1 * d2 - c2 * d1))
      m.d2 = invdet  * (a1 * (c2 * d3 - c3 * d2) +
                        a2 * (c3 * d1 - c1 * d3) +
                        a3 * (c1 * d2 - c2 * d1))
      m.d3 = -invdet * (a1 * (b2 * d3 - b3 * d2) +
                        a2 * (b3 * d1 - b1 * d3) +
                        a3 * (b1 * d2 - b2 * d1))
      m.d4 = invdet  * (a1 * (b2 * c3 - b3 * c2) +
                        a2 * (b3 * c1 - b1 * c3) +
                        a3 * (b1 * c2 - b2 * c1))
      m
    end

  end

end
