module Assimp

  callback :log_stream_callback, [:string, :string], :void

  class LogStream < FFI::Struct
    extend StructAccessors
    layout :callback, :log_stream_callback,
           :user, :pointer
    struct_attr_reader :callback, :user

    def self.detach_all
      Assimp::aiDetachAllLogStreams
      self
    end

    def self.debugger
      Assimp::aiGetPredefinedLogStream(:DEBUGGER, nil)
    end

    def self.file(path)
      Assimp::aiGetPredefinedLogStream(:FILE, path)
    end

    def self.stdout
      Assimp::aiGetPredefinedLogStream(:STDOUT, nil)
    end

    def self.stderr
      Assimp::aiGetPredefinedLogStream(:STDERR, nil)
    end

    def self.verbose(bool)
      Assimp::aiEnableVerboseLogging(bool)
      self
    end

    def self.error_string
      Assimp::aiGetErrorString
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
      Assimp::aiAttachLogStream(self)
    end

    def callback=(c)
      @block = c
      self[:callback] = c
    end

    def detach
      Assimp::aiDetachLogStream(self)
    end

  end

  typedef :int, :bool

  FALSE = 0
  TRUE = 1

  attach_function :aiApplyPostProcessing, [Scene.by_ref, PostProcessSteps], :pointer
  attach_function :aiGetPredefinedLogStream, [DefaultLogStream, :string], LogStream.by_value
  attach_function :aiAttachLogStream, [LogStream.by_ref], :void
  attach_function :aiEnableVerboseLogging, [:bool], :void
  attach_function :aiDetachLogStream, [LogStream.by_ref], Return
  attach_function :aiDetachAllLogStreams, [], :void
  attach_function :aiGetErrorString, [], :string

  class PropertyStore < FFI::ManagedStruct
    layout :dummy, :char

    def initialize
      super(Assimp::aiCreatePropertyStore)
    end

    def self.release(ptr)
      Assimp::aiReleasePropertyStore(ptr)
    end

    def self.config_setter(*args)
      args.each { |name, type|
        prop = name.upcase.to_s
        meth_name = name.to_s.downcase + "="
        if type == :bool
          define_method(meth_name) do |bool|
            raise "Invalid bool value #{bool.inspect}" unless bool == Assimp::TRUE || bool == Assimp::FALSE
            Assimp::aiSetImportPropertyInteger(self, prop, bool)
            bool
          end
        elsif type == :int
          define_method(meth_name) do |val|
            Assimp::aiSetImportPropertyInteger(self, prop, val)
            val
          end
        elsif type == :float
          define_method(meth_name) do |val|
            Assimp::aiSetImportPropertyFloat(self, prop, val)
            val
          end
        elsif type == :matrix4x4
          define_method(meth_name) do |mat|
            Assimp::aiSetImportPropertyMatrix(self, prop, mat)
            mat
          end
        elsif type == :string
          define_method(meth_name) do |str|
            s = String::new
            s.data = str
            Assimp::aiSetImportPropertyString(self, prop, s)
            str
          end
        elsif type == :string_array
          define_method(meth_name) do |args|
            str = args.collect { |a| a =~ /\s/ ? "\'"+a+"\'" : a }.join(" ")
            s = String::new
            s.data = str
            Assimp::aiSetImportPropertyString(self, prop, s)
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

  attach_function :aiCreatePropertyStore, [], :pointer
  attach_function :aiReleasePropertyStore, [:pointer], :void
  attach_function :aiSetImportPropertyInteger, [PropertyStore.by_ref, :string, :int], :void
  attach_function :aiSetImportPropertyFloat, [PropertyStore.by_ref, :string, :ai_real], :void
  attach_function :aiSetImportPropertyString, [PropertyStore.by_ref, :string, String.by_ref], :void
  attach_function :aiSetImportPropertyMatrix, [PropertyStore.by_ref, :string, Matrix4x4.by_ref], :void

  attach_function :aiImportFile, [:string, PostProcessSteps], Scene.by_ref
  attach_function :aiImportFileEx, [:string, PostProcessSteps, FileIO.by_ref], Scene.by_ref
  attach_function :aiImportFileExWithProperties, [:string, PostProcessSteps, FileIO.by_ref, PropertyStore.by_ref], Scene.by_ref

  def self.import_file(file, flags: 0, fs: nil, props: nil)
    if props
      s = Assimp::aiImportFileExWithProperties(file, flags, fs, props)
    else
      s = Assimp::aiImportFileEx(file, flags, fs)
    end
    raise "Could not load model #{file}: #{Assimp::LogStream::error_string}!" if s.pointer.null?
    s
  end

  attach_function :aiImportFileFromMemory, [:pointer, :uint, :uint, :string], Scene.by_ref
  attach_function :aiImportFileFromMemoryWithProperties, [:pointer, :uint, :uint, :string, PropertyStore.by_ref], Scene.by_ref

  def self.import_file_from_memory(buffer, flags: 0, hint: "", props: nil)
    if props
      s = Assimp::aiImportFileFromMemoryWithProperties(buffer, buffer.size, flags, hint, props)
    else
      s = Assimp::aiImportFileFromMemory(buffer, buffer.size, flags, hint)
    end
    raise "Could not load model: #{Assimp::LogStream::error_string}!" if s.pointer.null?
    s
  end

  attach_function :aiReleaseImport, [Scene.by_ref], :void
  attach_function :aiIsExtensionSupported, [:string], :bool

  def self.extension_supported?(extension)
    Assimp::aiIsExtensionSupported(extension)
  end

  attach_function :aiGetExtensionList, [String.by_ref], :void

  def self.extension_list
    s = String::new
    Assimp::aiGetExtensionList(s)
    s
  end

  attach_function :aiGetMemoryRequirements, [Scene.by_ref, MemoryInfo.by_ref], :void

  attach_function :aiCreateQuaternionFromMatrix, [Quaternion.by_ref, Matrix3x3.by_ref], :void
  attach_function :aiDecomposeMatrix, [Matrix4x4.by_ref, Vector3D.by_ref, Quaternion.by_ref, Vector3D.by_ref], :void
  attach_function :aiTransposeMatrix4, [Matrix4x4.by_ref], :void
  attach_function :aiTransposeMatrix3, [Matrix3x3.by_ref], :void
  attach_function :aiTransformVecByMatrix3, [Vector3D.by_ref, Matrix3x3.by_ref], :void
  attach_function :transform_vec_by_matrix4, :aiTransformVecByMatrix4, [Vector3D.by_ref, Matrix4x4.by_ref], :void
  attach_function :aiMultiplyMatrix4, [Matrix4x4.by_ref, Matrix4x4.by_ref], :void
  attach_function :aiMultiplyMatrix3, [Matrix3x3.by_ref, Matrix3x3.by_ref], :void
  attach_function :aiIdentityMatrix4, [Matrix4x4.by_ref], :void
  attach_function :aiIdentityMatrix3, [Matrix3x3.by_ref], :void
  attach_function :aiGetImportFormatCount, [], :size_t
  attach_function :aiGetImportFormatDescription, [:size_t], ImporterDesc.by_ref

  def self.import_format_descriptions
    count = Assimp::aiGetImportFormatCount
    count.times.collect { |i| aiGetImportFormatDescription(i) }
  end

end
