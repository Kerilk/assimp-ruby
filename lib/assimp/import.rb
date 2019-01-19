module Assimp

  callback :log_stream_callback, [:string, :string], :void

  class LogStream < FFI::Struct
    extend StructAccessors
    layout :callback, :log_stream_callback,
           :user, :pointer
    struct_attr_reader :callback, :user

    def self.detach_all
      Assimp::detach_all_log_streams
    end

    def self.debugger
      Assimp::get_predefined_log_stream(:DEBUGGER, nil)
    end

    def self.file(path)
      Assimp::get_predefined_log_stream(:FILE, path)
    end

    def self.stdout
      Assimp::get_predefined_log_stream(:STDOUT, nil)
    end

    def self.stderr
      Assimp::get_predefined_log_stream(:STDERR, nil)
    end

    def user=(mess)
      @user = FFI::MemoryPointer.from_string(mess)
      self[:user] = @user
    end

    def attach(&block)
      if block_given?
        @block = FFI::Function.new(:void, [:string, :string], &block)
        self[:callback] = @block
      end
      Assimp::attach_log_stream(self)
    end

    def callback=(c)
      @block = c
      self[:callback] = c
    end

    def detach
      Assimp::detach_log_stream(self)
    end

  end

  class PropertyStore < FFI::ManagedStruct
    layout :dummy, :char

    def initialize
      super(Assimp.create_property_store)
    end

    def self.release(ptr)
      Assimp.release_property_store(ptr)
    end

    def self.config_setter(*args)
      args.each { |name, type|
        prop = name.upcase.to_s
        meth_name = name.to_s.downcase + "="
        if type == :bool
          define_method(meth_name) do |bool|
            raise "Invalid bool value #{bool.inspect}" unless bool == Assimp::TRUE || bool == Assimp::FALSE
            Assimp.set_import_property_integer(self, prop, bool)
            bool
          end
        elsif type == :int
          define_method(meth_name) do |val|
            Assimp.set_import_property_integer(self, prop, val)
            val
          end
        elsif type == :float
          define_method(meth_name) do |val|
            Assimp.set_import_property_float(self, prop, val)
            val
          end
        elsif type == :matrix4x4
          define_method(meth_name) do |mat|
            Assimp.set_import_property_matrix(self, prop, mat)
            mat
          end
        elsif type == :string
          define_method(meth_name) do |str|
            s = String::new
            s.data = str
            Assimp.set_import_property_string(self, prop, s)
            str
          end
        elsif type == :string_array
          define_method(meth_name) do |args|
            str = args.collect { |a| a =~ /\s/ ? "\'"+a+"\'" : a }.join(" ")
            s = String::new
            s.data = str
            Assimp.set_import_property_string(self, prop, s)
            args
          end
        end
      }
    end

    config_setter [:glob_measure_time, :bool],
                  [:import_no_skeleton_meshes, :bool],
                  [:pp_sbbc_max_bones, :int],
                  [:pp_ct_max_smoothing_angle, :float],
                  [:pp_ct_texture_channel_index, :int],
                  [:pp_gsn_max_smoothing_angle, :float],
                  [:import_mdl_colormap, :string],
                  [:pp_rrm_exclude_list, :string_array],
                  [:pp_ptv_keep_hierarchy, :bool],
                  [:pp_ptv_normalize, :bool],
                  [:pp_ptv_add_root_transformation, :bool],
                  [:pp_ptv_root_transformation, :matrix4x4],
                  [:pp_fd_remove, :bool],
                  [:pp_fd_checkarea, :bool],
                  [:pp_og_exclude_list, :string_array],
                  [:pp_slm_triangle_limit, :int],
                  [:pp_slm_vertex_limit, :int],
                  [:pp_lbw_max_weights, :int],
                  [:pp_db_threshold, :float],
                  [:pp_db_all_or_none, :bool],
                  [:pp_icl_ptcache_size, :int]

  end

  typedef :int, :bool

  FALSE = 0
  TRUE = 1

  attach_function :import_file, :aiImportFile, [:string, PostProcessSteps], Scene.by_ref
  attach_function :import_file_ex, :aiImportFileEx, [:string, PostProcessSteps, FileIO.by_ref], Scene.by_ref
  attach_function :import_file_ex_with_properties, :aiImportFileExWithProperties, [:string, PostProcessSteps, FileIO.by_ref, PropertyStore.by_ref], Scene.by_ref
  attach_function :import_file_from_memory, :aiImportFileFromMemory, [:pointer, :uint, :uint, :string], Scene.by_ref
  attach_function :import_file_from_memory_with_properties, :aiImportFileFromMemoryWithProperties, [:pointer, :uint, :uint, :string, PropertyStore.by_ref], Scene.by_ref
  attach_function :apply_post_processing, :aiApplyPostProcessing, [Scene.by_ref, PostProcessSteps], :pointer
  attach_function :get_predefined_log_stream, :aiGetPredefinedLogStream, [DefaultLogStream, :string], LogStream.by_value
  attach_function :attach_log_stream, :aiAttachLogStream, [LogStream.by_ref], :void
  attach_function :enable_verbose_logging, :aiEnableVerboseLogging, [:bool], :void
  attach_function :detach_log_stream, :aiDetachLogStream, [LogStream.by_ref], Return
  attach_function :detach_all_log_streams, :aiDetachAllLogStreams, [], :void
  attach_function :release_import, :aiReleaseImport, [Scene.by_ref], :void
  attach_function :get_error_string, :aiGetErrorString, [], :string
  alias error_string get_error_string
  attach_function :is_extension_supported, :aiIsExtensionSupported, [:string], :bool
  alias extension_supported? is_extension_supported
  attach_function :get_extension_list, :aiGetExtensionList, [String.by_ref], :void
  attach_function :get_memory_requirements, :aiGetMemoryRequirements, [Scene.by_ref, MemoryInfo.by_ref], :void
  attach_function :create_property_store, :aiCreatePropertyStore, [], :pointer
  attach_function :release_property_store, :aiReleasePropertyStore, [:pointer], :void
  attach_function :set_import_property_integer, :aiSetImportPropertyInteger, [PropertyStore.by_ref, :string, :int], :void
  attach_function :set_import_property_float, :aiSetImportPropertyFloat, [PropertyStore.by_ref, :string, :ai_real], :void
  attach_function :set_import_property_string, :aiSetImportPropertyString, [PropertyStore.by_ref, :string, String.by_ref], :void
  attach_function :set_import_property_matrix, :aiSetImportPropertyMatrix, [PropertyStore.by_ref, :string, Matrix4x4.by_ref], :void
  attach_function :create_quaternion_from_matrix, :aiCreateQuaternionFromMatrix, [Quaternion.by_ref, Matrix3x3.by_ref], :void
  attach_function :decompose_matrix, :aiDecomposeMatrix, [Matrix4x4.by_ref, Vector3D.by_ref, Quaternion.by_ref, Vector3D.by_ref], :void
  attach_function :transpose_matrix4, :aiTransposeMatrix4, [Matrix4x4.by_ref], :void
  attach_function :transpose_matrix3, :aiTransposeMatrix3, [Matrix3x3.by_ref], :void
  attach_function :transform_vec_by_matrix3, :aiTransformVecByMatrix3, [Vector3D.by_ref, Matrix3x3.by_ref], :void
  attach_function :transform_vec_by_matrix4, :aiTransformVecByMatrix4, [Vector3D.by_ref, Matrix4x4.by_ref], :void
  attach_function :multiply_matrix4, :aiMultiplyMatrix4, [Matrix4x4.by_ref, Matrix4x4.by_ref], :void
  attach_function :multiply_matrix3, :aiMultiplyMatrix3, [Matrix3x3.by_ref, Matrix3x3.by_ref], :void
  attach_function :identity_matrix4, :aiIdentityMatrix4, [Matrix4x4.by_ref], :void
  attach_function :identity_matrix3, :aiIdentityMatrix3, [Matrix3x3.by_ref], :void
  attach_function :get_import_format_count, :aiGetImportFormatCount, [], :size_t
  attach_function :get_import_format_description, :aiGetImportFormatDescription, [:size_t], ImporterDesc.by_ref

end
