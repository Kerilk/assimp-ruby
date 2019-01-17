module Assimp

  ImporterFlags = bitmask(:importer_flags, [
    :SupportTextFlavour,
    :SupportBinaryFlavour,
    :SupportCompressedFlavour,
    :LimitedSupport,
    :Experimental
  ])

  class ImporterDesc < FFI::Struct
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
  end

  #Following function is not found in the ubuntu distribution
  #attach_function :get_importer_desc, :aiGetImporterDesc, [:string], ImporterDesc.ptr

end
