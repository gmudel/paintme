//
//  styleSelectorVC.swift
//  paintme
//
//  Created by Megan Worrel on 12/18/20.
//

import UIKit

class styleSelectorVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func browseClicked(_ sender: Any) {
        let paintingsVC = storyboard!.instantiateViewController(withIdentifier: "paintingTableVC") as! paintingTableVC
        paintingsVC.image = self.image
        self.navigationController?.pushViewController(paintingsVC, animated: true)
    }
    
    @IBAction func photosClicked(_ sender: Any) {
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .photoLibrary
        photoPicker.allowsEditing = true
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let editedImage = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        //print(image.size)
        
        let waitingVC = storyboard!.instantiateViewController(withIdentifier: "waitingVC") as! waitingVC
        waitingVC.inputImage = self.image
        waitingVC.styleImage = editedImage
        self.navigationController?.pushViewController(waitingVC, animated: true)
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
