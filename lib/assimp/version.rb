module Assimp
  attach_function :get_legal_string, :aiGetLegalString, [], :string
  attach_function :get_version_minor, :aiGetVersionMinor, [], :uint
  attach_function :get_version_major, :aiGetVersionMajor, [], :uint
  attach_function :get_version_revision, :aiGetVersionRevision, [], :uint

  VERSION = "#{get_version_major}.#{get_version_minor}.#{get_version_revision}"

  CFlags = bitmask(:cflags, [
    :SHARED,
    :STLPORT,
    :DEBUG,
    :NOBOOST,
    :SINGLETHREADED
  ])

  attach_function :get_compile_flags, :aiGetCompileFlags, [], :cflags
end
