//
//  PaddedTextView.swift
//  Picnic
//
//  Created by Kyle Burns on 9/2/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class PaddedTextView: UITextView {

    public enum Padding: CGFloat {
        case standard = 10
        case extra = 20
        case thin = 5
        case none = 0
    }

    private var inset: Padding = .standard
    
    var placeholder: String = "" {
        didSet {
            text = placeholder
        }
    }

    init() {
        super.init(frame: .zero, textContainer: nil)
        setPadding(inset)
        text = placeholder
        textColor = .lightGray
        isEditable = true
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func setPadding(_ amount: Padding) {
        inset = amount
        textContainerInset = UIEdgeInsets(top: amount.rawValue, left: amount.rawValue, bottom: amount.rawValue, right: amount.rawValue)
    }
}

extension PaddedTextView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        textView.endEditing(true)
        return true
    }
}
