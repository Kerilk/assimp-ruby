module Assimp

  class Node < FFI::Struct
    extend StructAccessors

    layout :name, String,
           :transformation, Matrix4x4,
           :parent, :pointer, #Node or null,
           :num_children, :uint,
           :children, :pointer, #Node*[num_chidren]
           :num_meshes, :uint,
           :meshes, :pointer, #uint[num_meshes]
           :meta_data, :pointer #Metadata.ptr

    struct_attr_accessor :name,
                         :transformation,
                         :num_children,
                         :num_meshes

    struct_ref_array_attr_accessor [:children, Node]

    struct_array_attr_accessor [:meshes, :uint]

    def initialize(ptr = nil)
      if ptr
        super
      else
        ptr = FFI::MemoryPointer::new(self.class.size, 1, true)
        super(ptr)
        transformation.identity!
      end
    end

    def parent
      ptr = self[:parent]
      return nil if ptr.null?
      Node::new(ptr)
    end

    def parent=(other)
      if other.kind_of? FFI::Pointer
        self[:parent] = other
      elsif other.kind_of? Node
        self[:parent] = other.pointer
      else
        raise ArgumentError::new("Argument should be a Node!")
      end
      other
    end

    def each_node(&block)
      if block then
        block.call self
        children.each { |c|
          c.each_node(&block)
        }
        return self
      else
        to_enum(:each_node)
      end
    end

    def meta_data
      p = self[:meta_data]
      return nil if p.null?
      Metadata::new(p)
    end

  end

  SceneFlags = bitmask(:scene_flags, [
    :INCOMPLETE,
    :VALIDATED,
    :VALIDATION_WARNING,
    :NON_VERBOSE_FORMAT,
    :FLAGS_TERRAIN,
    :FLAGS_ALLOW_SHARED
  ])

  class Scene < FFI::ManagedStruct
    extend StructAccessors

    layout :flags, SceneFlags,
           :root_node, Node.ptr,
           :num_meshes, :uint,
           :meshes, :pointer, #Mesh*[num_meshes]
           :num_materials, :uint,
           :materials, :pointer, #Material*[num_materials]
           :num_animations, :uint,
           :animations, :pointer, #Animation*[num_animations]
           :num_textures, :uint,
           :textures, :pointer, #Texture*[num_textures]
           :num_lights, :uint,
           :lights, :pointer, #Light*[num_lights]
           :num_cameras, :uint,
           :cameras, :pointer, #Camera*[num_cameras]
           :private, :pointer #void * really...

    struct_attr_accessor :flags,
                         :root_node,
                         :num_meshes,
                         :num_materials,
                         :num_animations,
                         :num_textures,
                         :num_lights,
                         :num_cameras,
                         :private

    struct_ref_array_attr_accessor [:meshes, Mesh],
                                   [:materials, Material],
                                   [:animations, Animation],
                                   [:textures, Texture],
                                   [:lights, Light],
                                   [:cameras, Camera]

    def self.inherited(klass)
      klass.instance_variable_set(:@layout, @layout)
    end

    def self.release(ptr)
      Assimp::aiReleaseImport(ptr)
    end

    def each_node(&block)
      if block then
        node = root_node
        node.each_node(&block)
        return self
      else
        to_enum(:each_obj)
      end
    end

    def apply_post_processing(steps)
      ptr = Assimp::aiApplyPostProcessing(self, steps)
      raise "Post processing failed!" if ptr.null?
      self
    end

    def memory_requirements
      m = Assimp::MemoryInfo::new
      Assimp::aiGetMemoryRequirements(self, m)
      m
    end

    def copy
      m = FFI::MemoryPointer::new(:pointer)
      Assimp::aiCopyScene(self, m)
      ptr = m.read_pointer
      raise "Could not copy scene: #{Assimp::LogStream::error_string}" if ptr.null?
      Assimp::SceneCopy::new(ptr)
    end

    def export(format_id, file_name, preprocessing: 0, io: nil)
      if io
        Assimp::aiExportSceneEx(self, format_id, file_name, io, preprocessing)
      else
        Assimp::aiExportScene(self, format_id, file_name, preprocessing)
      end
    end

    def export_to_blob(format_id, preprocessing: 0)
      ptr = Assimp::aiExportSceneToBlob(self, format_id, preprocessing)
      raise "Could not export scene: #{Assimp::LogStream::error_string}" if ptr.null?
      Assimp::ExportDataBlob::new(FFI::AutoPointer::new(ptr, Assimp::ExportDataBlob::method(:releaser)))
    end

  end

  class SceneCopy < Scene

    def self.release(ptr)
      Assimp::aiFreeScene(ptr)
    end

  end

end
