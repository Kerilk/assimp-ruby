module Assimp

  class Camera < FFI::Struct
    layout :name, String,
           :position, Vector3D,
           :up, Vector3D,
           :look_at, Vector3D,
           :horizontal_fov, :float,
           :clip_plane_near, :float,
           :aspect, :float
  end

end
