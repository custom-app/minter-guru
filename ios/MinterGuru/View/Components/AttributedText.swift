//
//  AttributedText.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 20.08.2022.
//

import SwiftUI

struct AttributedText: UIViewRepresentable {
    
    var attributedString:NSAttributedString
    
    func makeUIView(context: Context) -> ViewWithLabel {
        let view = ViewWithLabel(frame:CGRect.zero)
        return view
    }
    
    func updateUIView(_ uiView: ViewWithLabel, context: UIViewRepresentableContext<AttributedText>) {
        uiView.setString(attributedString)
    }
}


class ViewWithLabel : UIView {
    private var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(label)
        label.numberOfLines = 0
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setString(_ attributedString:NSAttributedString) {
        self.label.attributedText = attributedString
    }
}
