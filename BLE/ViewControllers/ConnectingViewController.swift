//
//  LoadingViewController.swift
//
//  BLEScanner
//
//  Created by Tops on 17/03/20.
//  Copyright © 2020 GG. All rights reserved.
//

import UIKit

protocol ConnectingViewControllerDelegate: class {
    func didTapCancel(_ vc: ConnectingViewController)
}

class ConnectingViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingOverlayView: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    weak var delegate: ConnectingViewControllerDelegate?
    var peripheralName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Connecting to \(peripheralName)..."
        loadingOverlayView.layer.cornerRadius = 3
        cancelButton.layer.cornerRadius = 3
        self.navigationController?.navigationBar.backgroundColor = .blue

    }
    // to cancel the connection process
    @IBAction private func didTapCancelButton(_ sender: Any) {
        delegate?.didTapCancel(self)
    }
    
}
