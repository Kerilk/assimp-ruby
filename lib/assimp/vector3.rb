module Assimp

  class Vector3D < FFI::Struct
    extend StructAccessors
    layout :x, :ai_real,
           :y, :ai_real,
           :z, :ai_real

    struct_attr_accessor :x, :y, :z

    def to_s
      "<#{x}, #{y}, #{z}>"
    end

    def square_length
      x*x + y*y + z*z
    end

    def length
      Math::sqrt(square_length)
    end

    def set( x, y, z )
      self[:x] = x
      self[:y] = y
      self[:z] = z
      self
    end

    def -@
      v = Vector3D::new
      v.set(-x, -y, -z)
    end

    def +(other)
      v = Vector3D::new
      v.set(x + other.x,
            y + other.y,
            z + other.z)
    end

    def -(other)
      v = Vector3D::new
      v.set(x - other.x,
            y - other.y,
            z - other.z)
    end

    def *(other)
      v = Vector3D::new
      if other.kind_of? Vector3D
        v.set(x * other.x,
              y * other.y,
              z * other.z)
      else
        v.set(x * other,
              y * other,
              z * other)
      end
    end

    def ^(other)
      v = Vector3D::new
      v.set(y*other.z - z*other.y,
            z*other.x - x*other.z,
            x*other.y - y*other.x)
    end

    def /(other)
      v = Vector3D::new
      if other.kind_of? Vector3D
        v.set(x / other.x,
              y / other.y,
              z / other.z)
      else
        v.set(x / other,
              y / other,
              z / other)
      end
    end

    def normalize!
      l = length
      if l > 0.0
        self.x /= l
        self.y /= l
        self.z /= l
      end
      self
    end

    def normalize
      v = self.dup
      v.normalize!
    end

  end

end
