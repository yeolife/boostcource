//
//  ViewController_signIn.swift
//  SignUp
//
//  Created by yeolife on 2023/07/25.
//

import UIKit

class ViewController_signIn: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var id_TextField_signIn: UITextField!
    @IBOutlet weak var pw_TextField_signIn: UITextField!
    @IBOutlet weak var pwCheck_TextField_signIn: UITextField!
    @IBOutlet weak var introduce_signIn: UITextView!
    @IBOutlet weak var imageSelector_signIn: UIImageView!
    @IBOutlet weak var nextBtn_signIn: UIButton! {
        didSet {
            nextBtn_signIn.isEnabled = false
        }
    }
    
    // MARK: - Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.id_TextField_signIn.delegate = self
        self.pw_TextField_signIn.delegate = self
        self.pwCheck_TextField_signIn.delegate = self
        
        imageSelector_signIn.layer.borderWidth = 0.5
        imageSelector_signIn.layer.borderColor = UIColor.gray.cgColor
        
        self.imageSelector_signIn.isUserInteractionEnabled = true
        self.imageSelector_signIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.touchUpSelectImageView(_:))))
    }
    
    // 회원가입 취소하기
    @IBAction func dismiss_signIn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 텍스트 변경을 추적하여 빈칸 확인
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let isEmpty_id_TextField_signIn = !id_TextField_signIn.text!.isEmpty
        let isEmpty_pw_TextField_signIn = !pw_TextField_signIn.text!.isEmpty
        let isEmpty_pwCheck_TextField_signIn = !pwCheck_TextField_signIn.text!.isEmpty
        
        // 비밀번호 확인과 같은지 확인
        if(isEmpty_id_TextField_signIn && isEmpty_pw_TextField_signIn && isEmpty_pwCheck_TextField_signIn) {
            if(pw_TextField_signIn.text! == pwCheck_TextField_signIn.text!) {
                nextBtn_signIn.isEnabled = true
            }
            else {
                nextBtn_signIn.isEnabled = false
            }
        }
        else {
            nextBtn_signIn.isEnabled = false
        }
    }
    
    // MARK: - Image Function
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    @objc func touchUpSelectImageView(_ sender: UITapGestureRecognizer) {
        print("이미지뷰 클릭!")
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("피커 닫음!")
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageSelector_signIn.image = originalImage
        }
        self.dismiss(animated: true, completion: nil)
    }
}
