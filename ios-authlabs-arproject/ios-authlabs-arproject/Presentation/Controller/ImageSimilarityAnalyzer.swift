
import UIKit
import Vision

class ImageSimilarityAnalyzer {
    //MARK: 이미지를 VNFeaturePrintObservation으로 변환하는 함수
    private func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        let requestHandler = VNImageRequestHandler(data: imageData, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
    //MARK: 두 이미지 간의 유사성 측정 함수
    func measureSimilarityBetween(image1: UIImage, image2: UIImage) -> Float {
        guard let feature1 = featureprintObservationForImage(image: image1),
              let feature2 = featureprintObservationForImage(image: image2) else {
            fatalError("Unable to extract feature vectors for images.")
        }
        
        //MARK: 두 이미지 간의 거리 계산
        var distance = Float(0)
        do {
            try feature1.computeDistance(&distance, to: feature2)
            
            print("두 이미지 간의 유사도: \(1 - distance)")
        } catch {
            print("Error computing distance: \(error)")
        }
        
        return 1 - distance
    }
}
