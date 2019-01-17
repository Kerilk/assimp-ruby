[ '../lib', 'lib' ].each { |d| $:.unshift(d) if File::directory?(d) }
require 'minitest/autorun'
require 'assimp'

class AssimpTest < Minitest::Test

  def test_load
    scene = Assimp::import_file("duck.dae", 0)
    assert_equal(1, scene.num_meshes)
    p scene.meshes
    p scene.root_node
    p scene.root_node.parent
    p scene.root_node.meshes
    p scene.root_node.num_children
    p scene.root_node.children
    scene.each_node { |n|
      puts n.name
      puts n.num_children
    }
  end

end
