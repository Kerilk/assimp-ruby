module Assimp

  ImporterFlags = bitmask(:importer_flags, [
    :SupportTextFlavour,
    :SupportBinaryFlavour,
    :SupportCompressedFlavour,
    :LimitedSupport,
    :Experimental
  ])

  class ImporterDesc < FFI::Struct
    extend StructAccessors
    layout :name, :string,
           :author, :string,
           :maintainer, :string,
           :comments, :string,
           :flags, ImporterFlags,
           :min_major, :uint,
           :min_minor, :uint,
           :max_major, :uint,
           :max_minor, :uint,
           :file_extensions, :string
    struct_attr_reader :name,
                       :author,
                       :maintainer,
                       :comments,
                       :flags,
                       :min_major,
                       :min_minor,
                       :max_major,
                       :max_minor,
                       :file_extensions
    def to_s
      name
    end

  end

  #Following function is not found in the ubuntu distribution before 5.1?
  if version >= Version::new(5,1,0) then
    attach_function :aiGetImporterDesc, [:string], ImporterDesc.ptr

    def self.get_importer_desc(extension)
      self.aiGetImporterDesc(extension)
    end
  end

end
