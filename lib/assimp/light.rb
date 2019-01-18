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
    extend StructAccessors
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
    struct_attr_reader :name,
                       :type,
                       :position,
                       :direction,
                       :up,
                       :attenuation_constant,
                       :attenuation_linear,
                       :attenuation_quadratic,
                       :color_diffuse,
                       :color_dspecular,
                       :color_ambiant,
                       :angle_inner_cone,
                       :angle_outer_cone,
                       :size

    def to_s
      name.to_s
    end

  end

end
