[ '../lib', 'lib' ].each { |d| $:.unshift(d) if File::directory?(d) }
require 'minitest/autorun'
require 'assimp-ffi'

class AssimpTest < Minitest::Test

  def test_load
    #log = Assimp::get_predefined_log_stream(:STDERR, nil)
    log = Assimp::LogStream::new
    log.user = "hello"
    log.attach { |mess, user|
      $stderr.print user
      $stderr.print mess
    }
    Assimp::LogStream::verbose(Assimp::TRUE)
    scene = Assimp::import_file("duck.dae")
    log.detach
    assert_equal(1, scene.num_meshes)
    p scene.materials
    scene.materials.each { |m|
      p m.num_properties
      m.properties.each { |prop|
        puts prop
      }
    }
    p scene.meshes
    p scene.root_node
    p scene.root_node.parent
    p scene.root_node.meshes
    p scene.root_node.num_children
    p scene.root_node.children
    scene.each_node { |n|
      puts n.name
      puts n.transformation
      puts n.num_children
      p n.meshes
      p n.meta_data
      if n.meta_data
      p n.meta_data.num_properties
      end
    }
    scene.meshes.each { |m|
      p m.num_vertices
      m.vertices
      m.colors
      m.texture_coords
      p m.tangents
      p m.bitangents
      puts m.name
    }
    p scene.num_textures
    p scene.textures
    scene.apply_post_processing(0)
    prop = Assimp::PropertyStore::new
    prop.pp_og_exclude_list = ["a", "ab"]
    prop.pp_ptv_root_transformation = Assimp::Matrix4x4::new
    prop.pp_ptv_add_root_transformation = Assimp::TRUE
    prop.pp_gsn_max_smoothing_angle = 120.0
    prop.pp_ct_texture_channel_index = 3
  end

  def test_load_anim
    str = Assimp::String::new
    str.data = "toto"
    assert_equal( 4, str.length )
    assert_equal( "toto", str.to_s )
    puts Assimp::extension_list
    log = Assimp::LogStream::stderr
    log.attach
    Assimp::LogStream::verbose(Assimp::TRUE)
    scene = Assimp::import_file("astroBoy_walk_Maya.dae")
    scene.each_node { |n|
      puts n.name
      puts n.num_children
      puts n.num_meshes
      p n[:meta_data]
    }
    puts "-------------------------------------"
    scene.meshes.each { |m|
      puts m.name
    }
    p scene.memory_requirements.total
    Assimp::import_format_descriptions.each { |f| puts f }
    Assimp::export_format_descriptions.each { |f| puts f.id }
    puts Assimp::version
    puts Assimp::aiGetVersionMinor
    puts Assimp::compile_flags
    puts scene.export_to_blob("collada").size
    log.detach
    scene = nil
    GC.start
  end

end
