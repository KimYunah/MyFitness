//
//  MainViewController.swift
//  MyFitness
//
//  Created by UMC on 2023/01/24.
//

import UIKit
import CoreData
import Combine

class MainViewController: UIViewController, CalendarDelegate, AddViewControllerDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private let nowDate = Date()
    private let calendar = Calendar.current
    private var prevComponents = DateComponents()
    private var nextComponents = DateComponents()
    
    private var calendarList: [CalendarData] = []
    private var exerciseList: [Exercise] = []
    private var enableLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initData()
        getData()
        
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    private func initView() {
        let nibName = UINib(nibName: CalendarTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: CalendarTableViewCell.identifier)
    }
    
    private func initData() {
        var components = DateComponents()
        components.year = calendar.component(.year, from: nowDate)
        components.month = calendar.component(.month, from: nowDate)
        components.day = 1
        
        // 현재 월
        calendarList.insert(calculation(components: components), at: 0)
        
        // 이전 월
        prevComponents = components
        prevComponents.month = components.month! - 1
        calendarList.insert(calculation(components: prevComponents), at: 0)
        
        // 다음 월
        nextComponents = components
        nextComponents.month = nextComponents.month! + 1
        calendarList.append(calculation(components: nextComponents))
    }
    
    /**
     월 별 일 수 계산
     */
    private func calculation(components: DateComponents) -> CalendarData {
        let firstDayOfMonth = calendar.date(from: components)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth!) // 해당 수로 반환이 됩니다. 1은 일요일 ~ 7은 토요일
        let daysCountInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth!)!.count
        let weekdayAdding = 2 - firstWeekday // 이 과정을 해주는 이유는 예를 들어 2020년 4월이라 하면 4월 1일은 수요일 즉, 수요일이 달의 첫날이 됩니다.  수요일은 component의 4 이므로 CollectionView에서 앞의 3일은 비울 필요가 있으므로 인덱스가 1일부터 시작할 수 있도록 해줍니다. 그래서 2 - 4 해서 -2부터 시작하게 되어  정확히 3일 후부터 1일이 시작하게 됩니다.
        
        /*
         1 일요일 2 - 1  -> 0번 인덱스부터 1일 시작
         2 월요일 2 - 2  -> 1번 인덱스부터 1일 시작
         3 화요일 2 - 3  -> 2번 인덱스부터 1일 시작
         4 수요일 2 - 4  -> 3번 인덱스부터 1일 시작
         5 목요일 2 - 5  -> 4번 인덱스부터 1일 시작
         6 금요일 2 - 6  -> 5번 인덱스부터 1일 시작
         7 토요일 2 - 7  -> 6번 인덱스부터 1일 시작
         */
        
        let year = calendar.component(.year, from: firstDayOfMonth!)
        let month = calendar.component(.month, from: firstDayOfMonth!)
        
        var days: [Int] = []
        for day in weekdayAdding...daysCountInMonth {
            if day < 1 { // 1보다 작을 경우는 비워줘야 하기 때문에 빈 값을 넣어준다.
                days.append(-1)
            } else {
                days.append(day)
            }
        }
        
        return CalendarData(year: year, month: month, day: days)
        //        calendarList.insert(CalendarData(year: year, month: month, day: days), at: 0)
    }
    
    private func addCalendarData(isFront: Bool) {
        if isFront {
            prevComponents.month = prevComponents.month! - 1
            calendarList.insert(calculation(components: prevComponents), at: 0)
        } else {
            nextComponents.month = nextComponents.month! + 1
            calendarList.append(calculation(components: nextComponents))
        }
    }
    
    private func reload() {
        tableView.reloadData()
    }
    
    private func getData() {
        //        do {
        //            let data = try self.container.viewContext.fetch(Entity.fetchRequest()) as! [Entity]
        //            data.forEach {
        //                print($0.date)
        //                print($0.distance)
        //                print($0.time)
        //                print($0.kcal)
        //                  }
        //        } catch {
        //            print(error.localizedDescription)
        //        }
        exerciseList.removeAll()
        
        let data = CoreDataManager.shared.fetch(entity: Entity.self)
        data.forEach {
            let exercise = Exercise(date: $0.date,
                                    distance: $0.distance,
                                    time: $0.time,
                                    kcal: $0.kcal)
            exerciseList.append(exercise)
        }
        exerciseList.sort(by: { $0.date!.compare($1.date!) == .orderedAscending })
    }
    
    func getExercise(year: Int, month: Int) -> [Exercise] {
        var resultList: [Exercise] = []
        for exercise in exerciseList {
            if exercise.date?.year == year, exercise.date?.month == month {
                resultList.append(exercise)
            }
        }
        
        return resultList
    }
    
    func selectDate(date: Date?, exercise: Exercise?) {
        guard let date = date else {
            return
        }
        
        let addVC = AddViewController.instance("Main")
        addVC.delegate = self
        addVC.date = date
        if exercise != nil {
            addVC.isModify = true
            addVC.distance = exercise?.distance
            addVC.time = exercise?.time
            addVC.kcal = exercise?.kcal
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    func refresh() {
        getData()
        reload()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("tableView numberOfRowsInSection : \(calendarList.count)")
        return calendarList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("tableView cellForRowAt indexPath \(indexPath.row) data: \(calendarList[indexPath.row].month)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CalendarTableViewCell.identifier, for: indexPath) as? CalendarTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        if calendarList.count > indexPath.row {
            let data = calendarList[indexPath.row]
            let excersizeList = getExercise(year: data.year, month: data.month)
            cell.setData(calendar: data, exercise: excersizeList)
            cell.collectionView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = self.tableView.contentOffset.y
        let contentHeight = self.tableView.contentSize.height
        let boundsHeight = self.tableView.bounds.size.height
        //        print("contentOffset.y : \(self.tableView.contentOffset.y)")
        //        print("contentSize.height : \(self.tableView.contentSize.height)")
        //        print("bounds.size.height : \(self.tableView.bounds.size.height)")
        
        // Title Label 설정
        let y = offsetY + (boundsHeight/2)  // 좌표보정을 위해 절반의 높이를 더해줌
        let newPage = Int(y / boundsHeight)
        let calendar = calendarList[newPage]
        if !(self.label.text?.contains("\(calendar.month)월") ?? false) {
            self.label.text = "\(calendar.year)년 \(calendar.month)월"
        }
        
        // (이전 / 이후) 달력 정보 설정
        //        if contentHeight > 0, offsetY < boundsHeight + 20, !enableLoading {
        if offsetY < boundsHeight + 20, !enableLoading {
            //            print("앞에 도달")
            enableLoading = true
            
            let firstCalendar = calendarList[1]
            let firstMonth = calendarList[1].month
            // 추가
            addCalendarData(isFront: true)
            // scroll 이동
            DispatchQueue.main.async {
                let row = self.calendarList.firstIndex(where: {
                    $0.month == firstMonth && $0.year == firstCalendar.year
                }) ?? 1
                if row > -1 {
                    self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
                }
            }
            
            self.reload()
            enableLoading = false
        } else if offsetY >= (contentHeight - boundsHeight - 20), !enableLoading {
            //            print("끝에 도달")
            enableLoading = true
            
            // 추가
            addCalendarData(isFront: false)
            
            self.reload()
            enableLoading = false
        }
    }
}
