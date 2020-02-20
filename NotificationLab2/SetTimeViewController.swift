//
//  SetTimeViewController.swift
//  NotificationLab2
//
//  Created by Lilia Yudina on 2/20/20.
//  Copyright © 2020 Lilia Yudina. All rights reserved.
//

import UIKit
protocol CreateReminderControllerDelegate: AnyObject {
    func didCreateReminder(_ setTimeViewController: SetTimeViewController)
}

class SetTimeViewController: UIViewController {
    
    weak var delegate: CreateReminderControllerDelegate?
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5

    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func createLocalReminder() {
           let content = UNMutableNotificationContent()
           content.title = eventName.text ?? "no event name"
           content.body = "No content body"
           content.subtitle = "No subtitle"
           content.sound = .default
           let identifier = UUID().uuidString
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
           let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
           UNUserNotificationCenter.current().add(request) { (error) in
               if let error = error {
                   print("error adding request: \(error)")
               } else {
                   print("request was successfully added")
               }
           }
    }
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        guard sender.date > Date() else { return }
         timeInterval = sender.date.timeIntervalSinceNow
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        createLocalReminder()
             delegate?.didCreateReminder(self)
             dismiss(animated: true)
    }
    
}
