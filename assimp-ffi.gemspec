Gem::Specification.new do |s|
  s.name = 'assimp-ffi'
  s.version = "0.1.6"
  s.author = "Brice Videau"
  s.email = "brice.videau@imag.fr"
  s.homepage = "https://github.com/Kerilk/assimp-ruby"
  s.summary = "Open Asset Import Library bindings"
  s.description = "FFI bindings of Assimp (Open Asset Import Library bindings) for version 4.1.0 onward"
  s.files = Dir['assimp.gemspec', 'LICENSE', 'README.md', 'lib/**/*']
  s.has_rdoc = false
  s.license = 'BSD-2-Clause'
  s.required_ruby_version = '>= 2.1.0'
  s.add_dependency 'ffi', '~> 1.9', '>=1.9.19'
end
