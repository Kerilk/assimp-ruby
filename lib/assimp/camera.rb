module Assimp

  class Camera < FFI::Struct
    extend StructAccessors
    members = [
      :name, String,
      :position, Vector3D,
      :up, Vector3D,
      :look_at, Vector3D,
      :horizontal_fov, :float,
      :clip_plane_near, :float,
      :aspect, :float,
    ]
    members += [:orthographic_width, :float] if Assimp.version >= Assimp::Version.new(5,1,0)
    layout *members
    struct_attr_accessor :name,
                         :position,
                         :up,
                         :look_at,
                         :horizontal_fov,
                         :clip_plane_near,
                         :aspect
    if Assimp.version >= Assimp::Version.new(5,1,0) then
      struct_attr_accessor :orthographic_width
    end
    def to_s
      name
    end

  end

end
