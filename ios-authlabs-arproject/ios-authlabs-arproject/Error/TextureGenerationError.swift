enum TextureGenerationError: Error {
    case imageCreationFailed
    case imageDataCreationFailed
    case textureLoadingFailed
    case otherError(Error)
}
