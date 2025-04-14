module Assimp
  if version > Version::new(5,0,0)
    class AABB < FFI::Struct
      extend StructAccessors

      layout :min, Vector3D,
             :max, Vector3D

      struct_attr_accessor :min,
                           :max

      def to_s
        "{min: #{min}, max: #{max}}"
      end
    end
  end
end
