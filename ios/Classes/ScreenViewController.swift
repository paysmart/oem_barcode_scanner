//
//  ScreenViewController.swift
//  oem_barcode_scanner
//
//  Created by Natasha Flores on 9/24/20.
//

import UIKit

class ScreenViewController: UIView {



    override init(frame: CGRect = .zero){
        super.init(frame: frame)
        
        let viewDigitBarCode = UIView(frame: .zero)
        viewDigitBarCode.backgroundColor = .black
        viewDigitBarCode.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(viewDigitBarCode)
        
        viewDigitBarCode.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        viewDigitBarCode.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 15).isActive = true
        viewDigitBarCode.heightAnchor.constraint(equalToConstant: 70).isActive = true
        viewDigitBarCode.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 15).isActive = true
        
        let button = UIButton(frame: .zero)
        button.backgroundColor = .blue
        button.setTitle("Digitar código de barras", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        viewDigitBarCode.addSubview(button)
        
        backgroundColor = .darkGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
