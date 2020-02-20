//
//  ViewController.swift
//  NotificationLab2
//
//  Created by Lilia Yudina on 2/20/20.
//  Copyright © 2020 Lilia Yudina. All rights reserved.
//

import UIKit
import UserNotifications

class EventListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let center = UNUserNotificationCenter.current()
       
    private let pendingNotification = PendingNotification()
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        configureRefreshControll()
        checkForNotifications()
        loadReminders()
        center.delegate = self
    }
    
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         guard let navController = segue.destination as? UINavigationController, let setTimeVC = navController.viewControllers.first as? SetTimeViewController else {
             fatalError("could not downcast to SetTimerViewController")
         }
         setTimeVC.delegate = self
         }
   
    private func configureRefreshControll() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadReminders), for: .valueChanged)
    }
    
  @objc private func loadReminders() {
        pendingNotification.getPendingNotifications { (requests) in
            self.notifications = requests
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func checkForNotifications() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermission()
            }
        }
        
    }

    private func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization \(error)")
                return
            }
            if granted {
                print("access was granted")
            } else {
                print("access denied")
            }
        }
    }
}

extension EventListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeReminder(atIndexPath: indexPath)
        }
    }
    private func removeReminder(atIndexPath indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        notifications.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension EventListViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension EventListViewController: CreateReminderControllerDelegate {
    func didCreateReminder(_ setTimeViewController: SetTimeViewController) {
        loadReminders()
    }
}




