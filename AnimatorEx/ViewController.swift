//
//  ViewController.swift
//  AnimatorEx
//
//  Created by Emily Kolar on 12/8/18.
//  Copyright © 2018 Emily Kolar. All rights reserved.
//

import UIKit

private enum FocusState {
    case focused
    case unfocused
}

extension FocusState {
    var opposite: FocusState {
        switch self {
            case .focused: return .unfocused
            case .unfocused: return .focused
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var destView: UIView!
    @IBOutlet weak var transitionView: UIView!
    var transitionAnimator: UIViewPropertyAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        destView.layer.cornerRadius = 8
        destView.alpha = 0
        sourceView.alpha = 0
        sourceView.layer.zPosition = 1
        destView.layer.zPosition = 2
        transitionView.layer.zPosition = 3
        transitionView.addGestureRecognizer(tapRecognizer)
        transitionView.morphRectTo(sourceView)
    }
    
    private var currentState: FocusState = .unfocused
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(viewTapped(recognizer:)))
        return recognizer
    }()
    
    @objc private func viewTapped(recognizer: UITapGestureRecognizer) {
        print("tapped")
        transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            let state = self.currentState.opposite
            switch state {
            case .focused:
                self.transitionView.morphRectTo(self.destView)
                self.currentState = state
            case .unfocused:
                self.transitionView.morphRectTo(self.sourceView)
                self.currentState = state
            }
            self.view.layoutIfNeeded()
        })
        
        transitionAnimator?.startAnimation()
    }
    
}

public extension UIView {
    func transformTo(_ view: UIView) {
        transform = transformRect(from: frame, to: view.frame)
    }
    
    func morphRectTo(_ view: UIView, scale: CGFloat = 1) {
        guard let convertedFrame = superview?.convert(view.frame, from: view.superview) else {
            return
        }

        backgroundColor = view.backgroundColor

        layer.cornerRadius = view.layer.cornerRadius * scale
        frame = convertedFrame * scale
    }
    
    private func transformRect(from source: CGRect, to destination: CGRect) -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: destination.midX - source.midX,
                          y: destination.midY - source.midY)
            .scaledBy(x: destination.width / source.width,
                      y: destination.height / source.height)
    }
}

fileprivate extension CGRect {
    
    static func *(lhs: CGRect, rhs: CGFloat) -> CGRect {
        let scaledWidth = lhs.width * rhs
        let scaledHeight = lhs.height * rhs
        let x = lhs.origin.x + (lhs.width - scaledWidth) / 2
        let y = lhs.origin.y + (lhs.height - scaledHeight) / 2
        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
}

