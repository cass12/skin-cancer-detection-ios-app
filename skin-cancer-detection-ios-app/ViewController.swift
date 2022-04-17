import UIKit
import CoreML

@available(iOS 13.0, *)
class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var predLabel: UILabel!
        
    let model =  InceptionV3()
    override func viewDidLoad() {
        super.viewDidLoad()
        predLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func buttonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func getPrediction (forImage image:UIImage) -> Dictionary<String, Double>? {
        // var ret_val = Dictionary<String, Double>()
        
        //resize image to model input
        let newSize = CGSize(width: 224, height: 224)
        guard let resizedImage = image.resizeImageTo(size: newSize) else {
            fatalError("The image could not be found or resized.")
        }
        
        guard let convertedImage = resizedImage.convertToBuffer() else {
            fatalError("The image could not be converted to CVPixelBugger")
        }
        
        guard let prediction = try? model.prediction(inception_v3_input: convertedImage) else {
            fatalError("The model could not return a prediction")
        }
        return prediction.Identity

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

@available(iOS 13.0, *)
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var fullDict = ""
        
        if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            imageView.image = image
            //unhide results label
            predLabel.isHidden = false
            
            if let predictionDict = getPrediction(forImage: image) {
                for (class_label, confidence) in predictionDict {
                    fullDict += "\(class_label): \(confidence*100)%\n"
                }
                predLabel.text = fullDict
            }
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

