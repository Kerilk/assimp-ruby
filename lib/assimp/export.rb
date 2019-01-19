module Assimp

  class ExportFormatDesc < FFI::ManagedStruct
    extend StructAccessors
    layout :id, :string,
           :description, :string,
           :file_extension, :string
    struct_attr_reader :id,
                       :description,
                       :file_extension

    def self.release(ptr)
      Assimp::aiReleaseExportFormatDescription(ptr)
    end

  end

  attach_function :aiGetExportFormatCount, [], :size_t
  attach_function :aiGetExportFormatDescription, [:size_t], ExportFormatDesc.ptr
  attach_function :aiReleaseExportFormatDescription, [ExportFormatDesc.ptr], :void

  def self.export_format_descriptions
    count = Assimp::aiGetExportFormatCount
    count.times.collect { |i|
      Assimp::aiGetExportFormatDescription(i)
    }
  end

  attach_function :aiCopyScene, [Scene.ptr, :pointer], :void
  attach_function :aiFreeScene, [Scene.ptr], :void
  attach_function :aiExportScene, [Scene.ptr, :string, :string, PostProcessSteps], Return
  attach_function :aiExportSceneEx, [Scene.ptr, :string, :string, FileIO.ptr, PostProcessSteps], Return

  class ExportDataBlob < FFI::Struct
    extend StructAccessors
    layout :size, :size_t,
           :data, :pointer,
           :name, String,
           :next, ExportDataBlob.ptr
    struct_attr_reader :size,
                       :data,
                       :name,
                       :next
    
    def to_s
      name.to_s
    end

    def self.releaser(ptr)
      Assimp::aiReleaseExportBlob(ptr)
    end

  end

  attach_function :aiExportSceneToBlob, [Scene.ptr, :string, PostProcessSteps], :pointer #ExportDataBlob.ptr
  attach_function :aiReleaseExportBlob, [ExportDataBlob.ptr], :void

end
