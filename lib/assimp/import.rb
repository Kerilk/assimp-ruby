module Assimp

  callback :log_stream_callback, [:string, :string], :void

  class LogStream < FFI::Struct
    extend StructAccessors
    layout :callback, :log_stream_callback,
           :user, :pointer
    struct_attr_reader :callback, :user
  end

  class PropertyStore < FFI::Struct
    extend StructAccessors
    layout :sentinel, :char
    struct_attr_reader :sentinel
  end

  typedef :int, :bool

  FALSE = 0
  TRUE = 1

  attach_function :import_file, :aiImportFile, [:string, PostProcessSteps], Scene.ptr
  attach_function :import_file_ex, :aiImportFileEx, [:string, PostProcessSteps, FileIO.ptr], Scene.ptr
  attach_function :import_file_ex_with_properties, :aiImportFileExWithProperties, [:string, PostProcessSteps, FileIO.ptr, PropertyStore.ptr], Scene.ptr
  attach_function :import_file_from_memory, :aiImportFileFromMemory, [:pointer, :uint, :uint, :string], Scene.ptr
  attach_function :import_file_from_memory_with_properties, :aiImportFileFromMemoryWithProperties, [:pointer, :uint, :uint, :string, PropertyStore.ptr], Scene.ptr
  attach_function :apply_post_processing, :aiApplyPostProcessing, [Scene.ptr, :uint], Scene.ptr
  attach_function :get_predefined_log_stream, :aiGetPredefinedLogStream, [DefaultLogStream, :string], LogStream
  attach_function :attach_log_stream, :aiAttachLogStream, [LogStream.ptr], :void
  attach_function :enable_verbose_logging, :aiEnableVerboseLogging, [:bool], :void
  attach_function :detach_log_stream, :aiDetachLogStream, [LogStream.ptr], Return
  attach_function :detach_all_log_streams, :aiDetachAllLogStreams, [], :void
  attach_function :release_import, :aiReleaseImport, [Scene.ptr], :void
  attach_function :get_error_string, :aiGetErrorString, [], :string
  attach_function :is_extension_supported, :aiIsExtensionSupported, [:string], :bool
  attach_function :get_extension_list, :aiGetExtensionList, [String.ptr], :void
  attach_function :get_memory_requirements, :aiGetMemoryRequirements, [Scene.ptr, MemoryInfo.ptr], :void
  attach_function :create_property_store, :aiCreatePropertyStore, [], PropertyStore.ptr
  attach_function :release_property_store, :aiReleasePropertyStore, [PropertyStore.ptr], :void
  attach_function :set_import_property_integer, :aiSetImportPropertyInteger, [PropertyStore.ptr, :string, :int], :void
  attach_function :set_import_property_float, :aiSetImportPropertyFloat, [PropertyStore.ptr, :string, :ai_real], :void
  attach_function :set_import_property_string, :aiSetImportPropertyString, [PropertyStore.ptr, :string, String.ptr], :void
  attach_function :set_import_property_matrix, :aiSetImportPropertyMatrix, [PropertyStore.ptr, :string, Matrix4x4.ptr], :void
  attach_function :create_quaternion_from_matrix, :aiCreateQuaternionFromMatrix, [Quaternion.ptr, Matrix3x3.ptr], :void
  attach_function :decompose_matrix, :aiDecomposeMatrix, [Matrix4x4.ptr, Vector3D.ptr, Quaternion.ptr, Vector3D.ptr], :void
  attach_function :transpose_matrix4, :aiTransposeMatrix4, [Matrix4x4.ptr], :void
  attach_function :transpose_matrix3, :aiTransposeMatrix3, [Matrix3x3.ptr], :void
  attach_function :transform_vec_by_matrix3, :aiTransformVecByMatrix3, [Vector3D.ptr, Matrix3x3.ptr], :void
  attach_function :transform_vec_by_matrix4, :aiTransformVecByMatrix4, [Vector3D.ptr, Matrix4x4.ptr], :void
  attach_function :multiply_matrix4, :aiMultiplyMatrix4, [Matrix4x4.ptr, Matrix4x4.ptr], :void
  attach_function :multiply_matrix3, :aiMultiplyMatrix3, [Matrix3x3.ptr, Matrix3x3.ptr], :void
  attach_function :identity_matrix4, :aiIdentityMatrix4, [Matrix4x4.ptr], :void
  attach_function :identity_matrix3, :aiIdentityMatrix3, [Matrix3x3.ptr], :void
  attach_function :get_import_format_count, :aiGetImportFormatCount, [], :size_t
  attach_function :get_import_format_description, :aiGetImportFormatDescription, [:size_t], ImporterDesc.ptr

end
