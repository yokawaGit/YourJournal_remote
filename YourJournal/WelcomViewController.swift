//
//  WelcomViewController.swift
//  YourJournal
//
//  Created by 大川裕平 on 25/08/2023.
//

import UIKit
import LocalAuthentication

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "📓YourJournal"
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }

    @IBAction func authenticateButtonTapped(_ sender: UIButton) {
        
        authenticateUser()
        
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identity verification is required."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // 認証成功時のアクション
                        self.performSegue(withIdentifier: "ToJournal", sender: self)
                    } else {
                        // 認証失敗時のアクション
                        self.descLabel.text = "Identity verification failed."
                    }
                }
            }
        } else {
            // このメッセージは、デバイスがFace ID/Touch IDをサポートしていない場合、
            // またはその他の理由で認証ポリシーを評価できない場合に表示されます。
            print("Device does not support this authentication method.")
        }
    }

    
}
