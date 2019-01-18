module Assimp

  class ExportFormatDesc < FFI::Struct
    extend StructAccessors
    layout :id, :string,
           :description, :string,
           :file_extension, :string
    struct_attr_reader :id,
                       :description,
                       :file_extension
  end

  attach_function :get_export_format_count, :aiGetExportFormatCount, [], :size_t
  attach_function :get_export_format_description, :aiGetExportFormatDescription, [:size_t], ExportFormatDesc.ptr
  attach_function :release_export_format_description, :aiReleaseExportFormatDescription, [ExportFormatDesc.ptr], :void
  attach_function :copy_scene, :aiCopyScene, [Scene.ptr, :pointer], :void
  attach_function :free_scene, :aiFreeScene, [Scene.ptr], :void
  attach_function :export_scene, :aiExportScene, [Scene.ptr, :string, :string, PostProcessSteps], Return
  attach_function :export_scene_ex, :aiExportSceneEx, [Scene.ptr, :string, :string, FileIO.ptr, PostProcessSteps], Return

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

  end

  attach_function :export_scene_to_blob, :aiExportSceneToBlob, [Scene.ptr, :string, PostProcessSteps], ExportDataBlob.ptr
  attach_function :release_export_blob, :aiReleaseExportBlob, [ExportDataBlob.ptr], :void

end
