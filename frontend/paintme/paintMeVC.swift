//
//  paintMeVC.swift
//  paintme
//
//  Created by Megan Worrel on 12/13/20.
//

import UIKit

class paintMeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraClicked(_ sender: Any) {
        /*
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
 */
        let stylepicker = storyboard!.instantiateViewController(withIdentifier: "paintingTableVC") as! paintingTableVC
        self.present(stylepicker, animated: false, completion: nil)
    }
    
    @IBAction func photosClicked(_ sender: Any) {
        /*
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .photoLibrary
        photoPicker.allowsEditing = true
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
 */
        let stylepicker = storyboard!.instantiateViewController(withIdentifier: "paintingTableVC") as! paintingTableVC
        self.present(stylepicker, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
        
        let stylepicker = paintingTableVC()
        self.present(stylepicker, animated: false, completion: nil)
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
