[ '../lib', 'lib' ].each { |d| $:.unshift(d) if File::directory?(d) }
require 'minitest/autorun'
require 'assimp'

class AssimpTest < Minitest::Test

  def test_load
    scene = Assimp::import_file("duck.dae", 0)
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
  end

end
