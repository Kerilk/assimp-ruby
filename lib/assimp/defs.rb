module Assimp

  if ENV["ASSIMP_DOUBLE_PRECISION"]
    typedef :double, :ai_real
    typedef :long_long, :ai_int
    typedef :ulong_long, :ai_uint
  else
    typedef :float, :ai_real
    typedef :int, :ai_int
    typedef :uint, :ai_uint
  end

  MATH_PI = 3.141592653589793238462643383279
  MATH_TWO_PI = MATH_PI * 2.0
  MATH_HALF_PI = MATH_PI * 0.5

  def deg_to_rad(x)
    x * 0.0174532925
  end

  def rad_to_deg(x)
    x * 57.2957795
  end

end
