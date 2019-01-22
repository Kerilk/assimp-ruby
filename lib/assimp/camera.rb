module Assimp

  class Camera < FFI::Struct
    extend StructAccessors
    layout :name, String,
           :position, Vector3D,
           :up, Vector3D,
           :look_at, Vector3D,
           :horizontal_fov, :float,
           :clip_plane_near, :float,
           :aspect, :float
    struct_attr_accessor :name,
                         :position,
                         :up,
                         :look_at,
                         :horizontal_fov,
                         :clip_plane_near,
                         :aspect
    def to_s
      name
    end

  end

end
