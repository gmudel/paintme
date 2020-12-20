//
//  waitingVC.swift
//  paintme
//
//  Created by Megan Worrel on 12/18/20.
//

import UIKit
import SwiftyJSON

class waitingVC: UIViewController {

    @IBOutlet weak var waitingText: UILabel!
    @IBOutlet weak var indicator:
        UIActivityIndicatorView!
    @IBOutlet weak var finishedText: UILabel!
    @IBOutlet weak var image: UIImageView!
    var inputImage: UIImage!
    var styleImage: UIImage!
    @IBOutlet weak var downloadText: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = URL(string: "http://localhost:8000/paintme/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let contentData = inputImage.pngData() else { return }
        let content_image = contentData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        guard let styleData = styleImage.pngData() else { return }
        let style_image = styleData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        
        let parameters: [String: Any] = [
            "content_img": content_image,
            "style_img": style_image
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async{
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {
                        print("error", error ?? "Unknown error")
                        return
                    }

                    guard (200 ... 299) ~= response.statusCode else {
                        print("statusCode should be 2xx, but is \(response.statusCode)")
                        print("response = \(response)")
                        let alert = UIAlertController(title: "Error", message: "Error loading the image", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

                        self.present(alert, animated: true)
                        return
                    }
                    do {
                        let json = try JSON(data: data, options: .allowFragments)
                        let imageBase64 = json["img"].string
                        
                        let imageData = Data(base64Encoded: imageBase64 ?? "", options: .ignoreUnknownCharacters)!
                        
                        self.image.image = UIImage(data: imageData)
                    }
                    catch{
                        print("Error with JSON conversion")
                    }
                    
                    self.waitingText.isHidden = true
                    self.indicator.isHidden = true
                    self.finishedText.isHidden = false
                    self.image.isHidden = false
                    self.downloadText.isHidden = false
                    self.downloadButton.isHidden = false
                }
            }

        task.resume()
    }
    
    @IBAction func startoverClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func saveImageClicked(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image.image!, nil, nil, nil)
        let alert = UIAlertController(title: "Image Saved", message: nil, preferredStyle: .alert)

        self.present(alert, animated: true)
        alert.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
