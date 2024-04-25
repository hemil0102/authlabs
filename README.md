## ✦ 제출자

- SeSAC AI를 활용한 iOS 앱개발 과정 하업서

## ✦ 과제명

- AR활용 이미지 인식·검출·추적·증강 및 ChatGPT API 활용 이미지 검색·결과 출력 기능 개발

## ✦ 활용기술

- UIKit
- ARKit
- RealityKit 


## ✦ 구현사항

1. (구현) 마커로 활용할 이미지 선정
2. (구현) 마커를 활용하여 이미지 인식
3. (구현) 이미지 검출 및 추적 
4. (미구현) 마커로 인식한 이미지 캡처
5. (미구현) 캡처 이미지를 입력값으로 Chat GPT 유사 이미지 검색 및 3장 확보 
6. (미구현) 검색한 이미지 3장의 유사도 측정

## ✦ 상세 기능 구현 설명

**1. ARImageTrackingConfiguration()**

ARWorldTrackingConfiguration()으로 초반에 구현을 시도하였으나, 이미지 인식의 정확도가 ARImageTrackingConfiguration()가 더 뛰어나 해당 기술을 적용합니다. 

**2. resetTracking()**

```swift
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arConfiguration.trackingImages = referenceImages
        arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])

```
해당 코드를 통해서 Xcode AR Resource asset에 등록된 이미지로 이미지 인식을 수행합니다. 

**3. session(_ session: ARSession, didAdd anchors: [ARAnchor])**

ARSessionDelegate은 ARKit에서 제공하는 델리게이트로 
이미지 인식을 성공할 경우 인식한 이미지의 imageAnchor를 생성해줍니다.

이후 인식한 이미지 위에 인식했다는 표시를 하기 위해 detectPlaneMaterial 생성해줍니다. 
해당 과제에서는 반투명 흰색의 평면을 인식한 이미지 위에 표시해줬습니다. 

**4. UI와 Texture**

이미지 인식에 성공하였을 경우, 관련 정보를 보여줄 infomationPlaneEntity를 만들어주었습니다.
이 경우 UIView를 Entity위에 바로 올려주고 싶었는데, 관련 api나 예제를 찾지는 못하였고,
대신에 UIView를 이미지로 변환하고 이를 Texture로 활용하는 방식으로 정보를 표현했습니다.
마찬가지 방식으로 버튼의 Texture도 같은 방식으로 만들었습니다. 

```Swift
// extentions asImage() 메서드로 UIView를 UIImage로 변환 - Information View
arGuideView.isHidden = false
guard let arGuideViewImage = self.arGuideView.asImage().resized(toSize: CGSize(width: 200, height: 100)) else {
    return print("이미지 사이즈 조절에 실패했습니다.")
}
arGuideView.isHidden = true
            
// UIImage를 texture로 생성
let arGuideTemp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
guard let imageData = arGuideViewImage.jpegData(compressionQuality: 1.0) else {
    return print("UIImage로부터 데이터 생성에 실패했습니다.")
}
try! imageData.write(to: arGuideTemp)
guard let informationTexture = try? TextureResource.load(contentsOf: arGuideTemp) else {
    return print("이미지를 찾을 수 없습니다. ")
}

```

Texture를 입혀주면서 어려웠던 점은, 입히고나니 회색빛이 돌아서 이미지가 어두워보였고, 
이를 해결하기 위해서 아래와 같은 코드를 적용했습니다. 

```swift
arView.renderOptions = [.disableGroundingShadows]
var infomationPlaneMaterial = UnlitMaterial(color: .white)
infomationPlaneMaterial.color =  SimpleMaterial.BaseColor(tint: .white.withAlphaComponent(1), texture: .init(informationTexture))
```

그림자 효과를 제거해주며, Material을 무광 흰색으로 지정해줍니다. 

**5. Marker Model**
과제에서 제시된 마커의 구분과, 이미지의 정의(분류)를 아래 그림처럼 모델링하였습니다. 
```swift
arView.renderOptions = [.disableGroundingShadows]
var infomationPlaneMaterial = UnlitMaterial(color: .white)
infomationPlaneMaterial.color =  SimpleMaterial.BaseColor(tint: .white.withAlphaComponent(1), texture: .init(informationTexture))
```


## ✦ 확인방법

1. Xcode Asset 내부 AR Resource 파일의 이미지를 컴퓨터 모니터에 열어서 확인 가능

## ✦ 구동화면

![ezgif-4-01c5c65182](https://github.com/hemil0102/authlabs/assets/83139316/e1a3bcd6-cd59-407c-b9b9-28f8bb87f913)
