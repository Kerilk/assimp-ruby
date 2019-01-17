module Assimp

  PostProcessSteps = bitmask(:post_process_steps, [
    :CalcTangentSpace,
    :JoinIdenticalVertices,
    :MakeLeftHanded,
    :Triangulate,
    :RemoveComponent,
    :GenNormals,
    :GenSmoothNormals,
    :SplitLargeMeshes,
    :PreTransformVertices,
    :LimitBoneWeights,
    :ValidateDataStructure,
    :ImproveCacheLocality,
    :RemoveRedundantMaterials,
    :FixInfacingNormals,
    :SortByPType, 15,
    :FindDegenerates,
    :FindInvalidData,
    :GenUVCoords,
    :TransformUVCoords,
    :FindInstances,
    :OptimizeMeshes,
    :OptimizeGraph,
    :FlipUVs,
    :FlipWindingOrder,
    :SplitByBoneCount,
    :Debone,
    :GlobalScale
  ])

  ProcessPreset_ConvertToLeftHanded = Assimp::PostProcessSteps[
    :MakeLeftHanded,
    :FlipUVs,
    :FlipWindingOrder
  ]

  ProcessPreset_TargetRealtime_Fast = Assimp::PostProcessSteps[
    :CalcTangentSpace,
    :GenNormals,
    :JoinIdenticalVertices,
    :Triangulate,
    :GenUVCoords,
    :SortByPType 
  ]

  ProcessPreset_TargetRealtime_Quality = Assimp::PostProcessSteps[
    :CalcTangentSpace,
    :GenSmoothNormals,
    :JoinIdenticalVertices,
    :ImproveCacheLocality,
    :LimitBoneWeights,
    :RemoveRedundantMaterials,
    :SplitLargeMeshes,
    :Triangulate,
    :GenUVCoords,
    :SortByPType,
    :FindDegenerates,
    :FindInvalidData
  ]

  ProcessPreset_TargetRealtime_MaxQuality = Assimp::PostProcessSteps[
    :CalcTangentSpace,
    :GenSmoothNormals,
    :JoinIdenticalVertices,
    :ImproveCacheLocality,
    :LimitBoneWeights,
    :RemoveRedundantMaterials,
    :SplitLargeMeshes,
    :Triangulate,
    :GenUVCoords,
    :SortByPType,
    :FindDegenerates,
    :FindInvalidData,
    :FindInstances,
    :ValidateDataStructure,
    :OptimizeMeshes
  ]
 
end
