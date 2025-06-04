## ✦ 제출자

- SeSAC AI를 활용한 iOS 앱개발 과정 하업서

## ✦ 과제명

- AR활용 이미지 인식·검출·추적·증강 및 ChatGPT API 활용 이미지 검색·결과 출력 기능 개발

## ✦ 활용기술

- UIKit
- ARKit
- RealityKit
- Combine
- CoreImage
- Vision
- ChatGPT Vision API
- Google Custom Search API

## ✦ 결과화면 및 구현 사항
<img width="800" alt="Screenshot 2024-04-30 at 9 30 25 PM" src="https://github.com/hemil0102/authlabs/assets/83139316/5739ce54-47c0-444d-ad31-adcdfc2f5872">
<img width="800" alt="Screenshot 2024-04-30 at 9 30 32 PM" src="https://github.com/hemil0102/authlabs/assets/83139316/9f9ad520-1a5d-4676-a1a4-9eb2e2052b0f">
<img width="800" alt="Screenshot 2024-04-30 at 9 02 08 PM" src="https://github.com/hemil0102/authlabs/assets/83139316/fa0cb4a2-b89a-4735-9e50-a9276d43cae8">

## ✦ 상세 기능 구현 설명
1. 마커 등록
   asset에 ARResourc를 통해서 등록했습니다.

2. 이미지 인식 및 앵커 생성
```swift
       func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            handleImageAnchor(imageAnchor)
        }
    }
```

3. 이미지 트래킹
```swift
  func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        arConfiguration.trackingImages = referenceImages
        arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
```

4. 이미지 추출 - 이미지 모서리 꼭지점 계산
```swift
guard let topLeft = arView.project(imageAnchorPosition + SIMD3<Float>(-referenceImageWidth/2, referenceImageHeight/2, 0)),
              let bottomLeft = arView.project(imageAnchorPosition + SIMD3<Float>(-referenceImageWidth/2, -referenceImageHeight/2, 0)),
              let topRight = arView.project(imageAnchorPosition + SIMD3<Float>(referenceImageWidth/2, referenceImageHeight/2, 0)),
              let bottomRight = arView.project(imageAnchorPosition + SIMD3<Float>(referenceImageWidth/2, -referenceImageHeight/2, 0)) else { return }
```

5. 이미지 왜곡 보정 - CIImage
```swift
    private func cropImageForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage? {
        let perspectiveTransformFilter = CIFilter.perspectiveCorrection()
        perspectiveTransformFilter.inputImage = image
        perspectiveTransformFilter.topLeft = CGPoint(x: topLeft.x - 10, y: image.extent.size.height - topLeft.y + 40)
        perspectiveTransformFilter.topRight = CGPoint(x: topRight.x - 35, y: image.extent.size.height - topRight.y + 40)
        perspectiveTransformFilter.bottomLeft = CGPoint(x: bottomLeft.x - 10, y: image.extent.size.height - bottomLeft.y + 30)
        perspectiveTransformFilter.bottomRight = CGPoint(x: bottomRight.x - 35, y: image.extent.size.height - bottomRight.y + 30)
    
        return perspectiveTransformFilter.outputImage!
    }

```
6. 네트워크 통신
   클린 아키텍처와 Combine을 결합하여 통신을 구현했습니다. Data Layer내부 파일들을 확인 바랍니다. 
   
7. 유사도 측정
   ImageSimilarityAnalyzer에서 애플 Vision 프레임워크를 활용해서 이미지 간의 유사도 거리를 측정합니다.  

## ✦ 확인방법
1. 동봉된 Marker를 Asset ARResource에 등록하여 활용 (기본 printed 이미지 마커 등록되어 있음)

## ✦ 구동화면
![IMB_NC3mTu](https://github.com/hemil0102/authlabs/assets/83139316/56a0028a-f04b-4056-9055-4c262d031c2d)


