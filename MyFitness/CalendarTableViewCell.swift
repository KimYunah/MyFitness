//
//  CalendarTableViewCell.swift
//  MyFitness
//
//  Created by UMC on 2023/01/24.
//

import UIKit

protocol CalendarDelegate: AnyObject {
    func selectDate(date: Date?, excersize: Excersize?)
}

class CalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let identifier = "CalendarTableViewCell"
    
    private var calendarData: CalendarData?
    private var excersizeData: [Excersize]?
    
    var delegate: CalendarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let nibName = UINib(nibName: CalendarCollectionViewCell.identifier, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setData(calendar : CalendarData, excersize: [Excersize]) {
        self.calendarData = calendar
        self.excersizeData = excersize
    }
}

extension CalendarTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarData?.day.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("collectionView cellForRowAt indexPath \(indexPath.item)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.identifier, for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row % 7 == 0 { // 일요일
            cell.dayLabel.textColor = UIColor(named: "ff6868")
        } else if indexPath.row % 7 == 6 { // 토요일
            cell.dayLabel.textColor = UIColor(named: "318ffe")
        } else { // 월요일 좋아(평일)
            cell.dayLabel.textColor = UIColor(named: "black")
        }
        
        guard let data = self.calendarData else {
            return cell
        }
        
        let day = data.day[indexPath.item]
        if day > 0 {
            cell.dayLabel.text = String(day)
        } else {
            cell.dayLabel.text = ""
        }
        
        guard let excersizeData = self.excersizeData else {
            return cell
        }

        cell.contentsImage.backgroundColor = .clear
        for excersize in excersizeData {
            if day == excersize.date?.day {
                cell.contentsImage.backgroundColor = .orange
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let calendar = self.calendarData else {
            return
        }
        let dateComponents = DateComponents(year: calendar.year, month: calendar.month, day: Int(calendar.day[indexPath.item]))
        let date = Calendar.current.date(from: dateComponents)
        
        var excersize: Excersize?
        if let excersizeData = self.excersizeData {
            for item in excersizeData {
                if date?.day == item.date?.day {
                    excersize = item
                    break
                }
            }
        }
        
        self.delegate?.selectDate(date: date, excersize: excersize)
    }
}
