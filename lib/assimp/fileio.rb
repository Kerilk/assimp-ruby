module Assimp

  class FileIO < FFI::Struct
  end

  class File < FFI::Struct
  end

  callback :file_write_proc, [File.ptr, :string, :size_t, :size_t], :size_t
  callback :file_read_proc, [File.ptr, :string, :size_t, :size_t], :size_t
  callback :file_tell_proc, [File.ptr], :size_t
  callback :file_flush_proc, [File.ptr], :void
  callback :file_seek, [File.ptr, :size_t, Origin], Return

  callback :file_open_proc, [FileIO.ptr, :string, :string], File.ptr
  callback :file_close_proc, [FileIO.ptr, File.ptr], :void

  typedef :pointer, :user_data #byte

  class FileIO
    extend StructAccessors
    layout :open_proc, :file_open_proc,
           :close_proc, :file_close_proc,
           :user_data, :user_data
    struct_attr_reader :open_proc,
                       :close_proc,
                       :user_data
  end

  class File
    extend StructAccessors
    layout :read_proc, :file_read_proc,
           :write_proc, :file_write_proc,
           :tell_proc, :file_tell_proc,
           :file_size_proc, :file_tell_proc,
           :seek_proc, :file_seek,
           :flush_proc, :file_flush_proc,
           :user_data, :user_data
    struct_attr_reader :read_proc,
                       :write_proc,
                       :tell_proc,
                       :file_size_proc,
                       :seek_proc,
                       :flush_proc,
                       :user_data
  end

end
