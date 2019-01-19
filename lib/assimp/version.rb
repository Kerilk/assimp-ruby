module Assimp
  attach_function :aiGetLegalString, [], :string
  attach_function :aiGetVersionMinor, [], :uint
  attach_function :aiGetVersionMajor, [], :uint
  attach_function :aiGetVersionRevision, [], :uint

  class Version
    include Comparable
    attr_reader :major, :minor, :revision

    def initialize(major, minor, revision)
      @major = major
      @minor = minor
      @revision = revision
    end

    def <=>(other)
      res = (major <=> other.major)
      res = (minor <=> other.minor) if res == 0
      res = (revision <=> other.revision) if res == 0
      res
    end

    def to_s
      "#{major}.#{minor}.#{revision}"
    end

  end

  def self.version
    Version::new Assimp::aiGetVersionMajor, Assimp::aiGetVersionMinor, Assimp::aiGetVersionRevision
  end

  def self.legal_string
    Assimp::aiGetLegalString
  end

  CFlags = bitmask(:cflags, [
    :SHARED,
    :STLPORT,
    :DEBUG,
    :NOBOOST,
    :SINGLETHREADED
  ])

  attach_function :aiGetCompileFlags, [], :cflags

  def self.compile_flags
    Assimp::aiGetCompileFlags
  end

end
