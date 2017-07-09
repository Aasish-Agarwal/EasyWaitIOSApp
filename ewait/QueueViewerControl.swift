//
//  QueueViewerControl.swift
//  ewait
//
//  Created by Aakansha on 21/05/17.
//  Copyright © 2017 Smart Creatives. All rights reserved.
//

import UIKit

@IBDesignable class QueueViewerControl: UIStackView {

    @IBInspectable var queuePosition: String = "" {
        didSet {
            setupPositionViewLabel()
        }
    }

    @IBInspectable var queuePositionFontSize: Float = 30.0 {
        didSet {
            setupPositionViewLabel()
        }
    }
   
    var QueueName: String = "" {
        didSet {
            setupPositionViewLabel()
        }
    }
    var QueueServiceRate: String = "" {
        didSet {
            setupPositionViewLabel()
        }
    }
    var QueueId: String = "" {
        didSet {
            setupPositionViewLabel()
        }
    }
    var AcceptingAppointments: Bool = false {
        didSet {
            setupPositionViewLabel()
        }
    }
    var NextPosition: String = "" {
        didSet {
            setupPositionViewLabel()
        }
    }
    
    private var positionViewLabel = UILabel()
    private var qDetailStackView = UIStackView()
    private var qName = UILabel()
    private var qServiceRate = UILabel()
    private var qId = UILabel()

    private var AcceptingAppointmentsLabel = UILabel()
    private var NextPositionLabel = UILabel()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addArrangedSubview(positionViewLabel)
        
        qDetailStackView.axis = .vertical
        qDetailStackView.addArrangedSubview(qName)
        qDetailStackView.addArrangedSubview(qServiceRate)
        qDetailStackView.addArrangedSubview(qId)
        qDetailStackView.addArrangedSubview(AcceptingAppointmentsLabel)
        qDetailStackView.addArrangedSubview(NextPositionLabel)
        addArrangedSubview(qDetailStackView)
        
        setupPositionViewLabel()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        addArrangedSubview(positionViewLabel)

        qDetailStackView.axis = .vertical
        qDetailStackView.addArrangedSubview(qName)
        qDetailStackView.addArrangedSubview(qServiceRate)
        qDetailStackView.addArrangedSubview(qId)
        qDetailStackView.addArrangedSubview(AcceptingAppointmentsLabel)
        qDetailStackView.addArrangedSubview(NextPositionLabel)
        addArrangedSubview(qDetailStackView)

        setupPositionViewLabel()
    }
    
    //MARK: Private Methods
    
    private func setupPositionViewLabel() {
        qName.text = QueueName
        qServiceRate.text = QueueServiceRate
        qId.text = QueueId
        
        if ( QueueName.characters.count > 0 ) {
        if ( AcceptingAppointments )
        {
            AcceptingAppointmentsLabel.text = "Accepting Appointments"
            if ( NextPosition.characters.count > 0 )
            {
                NextPositionLabel.text = "Available Position: \(NextPosition)"
            }
        } else
        {
            AcceptingAppointmentsLabel.text = "Appointments Closed"
            NextPositionLabel.text = ""
            }
        }
        
        
        qName.translatesAutoresizingMaskIntoConstraints = false
        qServiceRate.translatesAutoresizingMaskIntoConstraints = false
        qId.translatesAutoresizingMaskIntoConstraints = false

        qName.textColor = UIColor.red
        qServiceRate.textColor = UIColor.brown
        qId.textColor = UIColor.blue
        
       
        positionViewLabel.backgroundColor = UIColor.green
        positionViewLabel.translatesAutoresizingMaskIntoConstraints = false
        positionViewLabel.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        positionViewLabel.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        positionViewLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(queuePositionFontSize))
        positionViewLabel.textAlignment = NSTextAlignment.center
        positionViewLabel.text = queuePosition
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
