//
//  ViewController_signUp.swift
//  SignUp
//
//  Created by yeolife on 2023/07/25.
//

import UIKit

class ViewController_signUp: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var id_TextField_signUp: UITextField!
    @IBOutlet weak var pw_TextField_signUp: UITextField!
    @IBOutlet weak var pwCheck_TextField_signUp: UITextField!
    @IBOutlet weak var introduce_signUp: UITextView?
    @IBOutlet weak var imageSelector_signUp: UIImageView!
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var nextBtn_signUp: UIButton! {
        didSet {
            nextBtn_signUp.isEnabled = false
        }
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.id_TextField_signUp.delegate = self
        self.pw_TextField_signUp.delegate = self
        self.pwCheck_TextField_signUp.delegate = self
        
        // 이미지뷰 디자인
        imageSelector_signUp.layer.borderWidth = 0.5
        imageSelector_signUp.layer.borderColor = UIColor.gray.cgColor
        self.imageSelector_signUp.isUserInteractionEnabled = true
        self.imageSelector_signUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController_signUp.touchUpSelectImageView(_:))))
        imageSelector_signUp.layer.masksToBounds = true
        
        // 이미지 고르기
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.allowsEditing = true
        self.imagePickerController.delegate = self
    }
    
    
    // MARK: - UI Function
    
    // 회원가입 취소하기
    @IBAction func dismiss_signUp() {
        cancleUserInformation_signUp()
        self.dismiss(animated: true, completion: nil)
    }
    
    // 텍스트 변경을 추적하여 빈칸 확인
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let isEmpty_id_TextField_signUp = !id_TextField_signUp.text!.isEmpty
        let isEmpty_pw_TextField_signUp = !pw_TextField_signUp.text!.isEmpty
        let isEmpty_pwCheck_TextField_signUp = !pwCheck_TextField_signUp.text!.isEmpty
        
        // 비밀번호 확인과 같은지 확인
        if(isEmpty_id_TextField_signUp && isEmpty_pw_TextField_signUp && isEmpty_pwCheck_TextField_signUp) {
            if(pw_TextField_signUp.text! == pwCheck_TextField_signUp.text!) {
                nextBtn_signUp.isEnabled = true
            }
            else {
                nextBtn_signUp.isEnabled = false
            }
        }
        else {
            nextBtn_signUp.isEnabled = false
        }
    }
    
    // 유저 정보 저장
    @IBAction func setUserInformation_signUp() {
        userInformation.shared.user_id = id_TextField_signUp.text
        userInformation.shared.user_password = pw_TextField_signUp.text
        userInformation.shared.user_introduce = introduce_signUp?.text
        userInformation.shared.user_profile = imageSelector_signUp.image
    }
    
    // 유저 정보 삭제
    func cancleUserInformation_signUp() {
        userInformation.shared.user_id = nil
        userInformation.shared.user_password = nil
        userInformation.shared.user_introduce = nil
        userInformation.shared.user_profile = nil
    }
    
    
    // MARK: - Image Function
    
    @objc func touchUpSelectImageView(_ sender: UITapGestureRecognizer) {
        print("이미지뷰 클릭!")
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("피커 닫음!")
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
  
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage

        // 이미지 선택 시 자르기
//        let cropRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
//        let imageRef = image.cgImage!.cropping(to: cropRect);
//        let newImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)

        imageSelector_signUp.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
}
