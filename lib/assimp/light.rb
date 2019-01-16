module Assimp

  LightSourceType = enum( :light_source_type, [
    :UNDEFINED,
    :DIRECTIONAL,
    :POINT,
    :SPOT,
    :AMBIENT,
    :AREA
  ])

  class Light < FFI::Struct
    layout :name, String,
           :type, LightSourceType,
           :position, Vector3D,
           :direction, Vector3D,
           :up, Vector3D,
           :attenuation_constant, :float,
           :attenuation_linear, :float,
           :attenuation_quadratic, :float,
           :color_diffuse, Color3D,
           :color_dspecular, Color3D,
           :color_ambiant, Color3D,
           :angle_inner_cone, :float,
           :angle_outer_cone, :float,
           :size, Vector2D
  end

end
