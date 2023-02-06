//
//  CalendarCollectionViewCell.swift
//  MyFitnes
//
//  Created by UMC on 2023/01/24.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var contentsImage: UIImageView!
    
    static let identifier = "CalendarCollectionViewCell"
    
    private var excersizeData: Excersize?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentsImage.layer.masksToBounds = true
        contentsImage.layer.cornerRadius = dayLabel.frame.width / 2
    }
    
    func setData(excersize: Excersize) {
        self.excersizeData = excersize
        
        dayLabel.text = String(excersize.date?.day ?? 0)
        contentsImage.backgroundColor = .orange
    }

    func setData(day : Int) {
        dayLabel.text = String(day)
        contentsImage.backgroundColor = .clear
    }
}
