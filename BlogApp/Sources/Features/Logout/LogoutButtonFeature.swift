//  Created by Bohdan Orlov on 01/03/2018.
//  Copyright © 2018 Bohdan Orlov. All rights reserved.
//

import Foundation
import UIKit
import Core
import Domain

class LogoutButtonFeature {
    private let sessionService: SessionServiceProtocol
    private let didLogout: () -> Void
    
    init(viewPresenter: ViewPresenter, sessionService: SessionServiceProtocol, didLogout: @escaping () -> Void) {
        self.sessionService = sessionService
        self.didLogout = didLogout
        self.observer = self.sessionService.observableSessionState.observeAndCall(weakify(self, type(of: self).updateUIState))
        viewPresenter.present(view: self.button)
    }
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints  = false
        button.setTitle("Logout", for: .normal)
        button.add(for: .touchUpInside) {
            // self captured intentionaly
            self.sessionService.stopSession()
        }
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private func updateUIState(_ session:SessionState) {
        switch session {
        case .started(_):
            self.button.isEnabled = true
        case .stopped:
            self.didLogout()
            fallthrough
        case .readyToStart: fallthrough
        case .starting: fallthrough
        case .failed(_):
            self.button.isEnabled = false
        }
    }
    
    private var observer: AnyObject?
}