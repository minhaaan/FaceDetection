import UIKit
import MLKitFaceDetection
import MLKitVision

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var button: UIButton!
  
  private lazy var overlayView: UIView = {
    let overlayView = UIView()
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    return overlayView
  }()
  
  private lazy var option: FaceDetectorOptions = {
    let option = FaceDetectorOptions()
    option.contourMode = .all
    option.performanceMode = .fast
    return option
  }()
  
  private lazy var faceDetector = FaceDetector.faceDetector(options: option)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    imageView.image = UIImage(named: "face1.jpg")
    
    view.addSubview(overlayView)
    NSLayoutConstraint.activate([
      overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
      overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
    ])
  }
  
  @IBAction func tap(_ sender: Any) {
    print("DEBUG: tapped..")
    runFaceDetection(with: imageView.image!)
  }
  
  func runFaceDetection(with image: UIImage) {
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    faceDetector.process(visionImage) { [weak self] feature, error in
      self?.processResult(from: feature, error: error)
    }
  }
  
  func processResult(from faces: [Face]?, error: Error?) {
    guard let faces else { return }
    
    for feature in faces {
      let transform = self.transformMatrix()
      let tranformedRect = feature.frame.applying(transform)
      self.addRectangle(tranformedRect, to: self.overlayView, color: UIColor.green)
    }
  }
  
  private func transformMatrix() -> CGAffineTransform {
    guard let image = imageView.image else { return CGAffineTransform() }
    let imageViewWidth = imageView.frame.size.width
    let imageViewHeight = imageView.frame.size.height
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    
    let imageViewAspectRatio = imageViewWidth / imageViewHeight
    let imageAspectRatio = imageWidth / imageHeight
    let scale =
    (imageViewAspectRatio > imageAspectRatio)
    ? imageViewHeight / imageHeight : imageViewWidth / imageWidth
    
    // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
    // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
    let scaledImageWidth = imageWidth * scale
    let scaledImageHeight = imageHeight * scale
    let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
    let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)
    
    var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
    transform = transform.scaledBy(x: scale, y: scale)
    return transform
  }
  
  private func addRectangle(_ rectangle: CGRect, to view: UIView, color: UIColor) {
    let rectangleView = UIView(frame: rectangle)
    rectangleView.layer.cornerRadius = 10.0
    rectangleView.alpha = 0.3
    rectangleView.backgroundColor = color
    view.addSubview(rectangleView)
  }
  
}

