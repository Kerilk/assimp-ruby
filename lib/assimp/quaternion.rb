module Assimp

  class Quaternion < FFI::Struct
    extend StructAccessors
    layout :w, :ai_real,
           :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real
    struct_attr_accessor :w, :x, :y, :z

    def to_s
      "{#{w}, #{x}, #{y}, #{z}}"
    end

    def conjugate
      q = Quaternion::new
      q.w = w
      q.x = -x
      q.y = -y
      q.z = -z
      q
    end

    def *(other)
      if other.kind_of?(Quaternion)
        q = Quaternion::new
        q.w = w*other.w - x*other.x - y*other.y - z*other.z
        q.x = w*other.x + x*other.w + y*other.z - z*other.y
        q.y = w*other.y + y*other.w + z*other.x - x*other.z
        q.z = w*other.z + z*other.w + x*other.y - y*other.x
        q
      elsif other.kind_of?(Vector3D)
        v = Vector3D::new
        q2 = Quaternion::new
        q2.x = other.x
        q2.y = other.y
        q2.z = other.z
        r = self * q2 * conjugate
        v.set(r.x, r.y, r.z)
      else
        raise "Unsupported operand: #{other.inspect}!"
      end
    end

  end

end
