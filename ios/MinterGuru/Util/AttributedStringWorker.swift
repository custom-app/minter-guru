//
//  AttributedStringWorker.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 20.08.2022.
//

import Foundation
import UIKit

class AttributedStringWorker {
    
    static let shared = AttributedStringWorker()
    
    func defaultOnboarding(string: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let wholeRange = string.startIndex ..< string.endIndex

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
//        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = 3.0
        attributedString.addAttributes(
            [.paragraphStyle : paragraphStyle,
             .font : UIFont(name: "rubik-regular", size: 18.0)!,
             .foregroundColor : UIColor.white,
             .strokeWidth : -1.0,
             .strokeColor : UIColor(Colors.darkGrey)], range: NSRange(wholeRange, in:string))
        addAttributes(string: string,
                      attrString: attributedString,
                      part: "GURU:",
                      attrs: [.foregroundColor : UIColor(Colors.brightBlue),
                              .font : UIFont(name: "rubik-bold", size: 18.0)!])
        return attributedString
    }
    
    func addAttributes(string: String, attrString: NSMutableAttributedString, part: String, attrs: [NSAttributedString.Key : Any]) {
        let range = string.range(of: part)!
        let nsRange = NSRange(range, in: string)
        attrString.addAttributes(attrs, range: nsRange)
    }
    
    var onboardingFirst: NSAttributedString {
        let string = "GURU: Hello, Stranger! Here you may IMMORTALIZE your memories (photos) in the eternal blockchain space. I will teach you the Mint spell that will turn your photo into an nft."
        let attrString = defaultOnboarding(string: string)
        addAttributes(string: string, attrString: attrString,
                      part: "IMMORTALIZE", attrs: [.foregroundColor : UIColor(Colors.brightGreen)])
        return attrString
    }
    
    var onboardingSecond: NSAttributedString {
        let string = "GURU: Any magic NFT is eternal on blockchain and can be listed and sold on any NFT Marketplace."
        return defaultOnboarding(string: string)
    }
    
    var onboardingThird: NSAttributedString {
        let string = "GURU: Every time you mint tweet about it, the magic smartcontract will reward you with 6 $MIGU tokens. Follow @MinterGuru on Twitter to receive 2 $MIGU tokens."
        let attrString = defaultOnboarding(string: string)
        addAttributes(string: string, attrString: attrString,
                      part: "@MinterGuru", attrs: [.foregroundColor : UIColor(Colors.brightGreen)])
        return attrString
    }
    
    var onboardingFourth: NSAttributedString {
        let string = "GURU: You will need 20 $MIGU to activate the spell and get your own NFT collection smartcontract deployed on Polygon."
        return defaultOnboarding(string: string)
    }
    
    var onboardingFifth: NSAttributedString {
        let string = "GURU: If you sell the Access Token of the Collection's smartcontract, then all unsold NFTs inside it will also be transferred to the buyer."
        return defaultOnboarding(string: string)
    }
}
