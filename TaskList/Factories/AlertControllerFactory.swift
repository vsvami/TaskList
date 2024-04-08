//
//  AlertControllerFactory.swift
//  TaskList
//
//  Created by Vladimir Dmitriev on 07.04.24.
//

import UIKit

protocol AlertFactoryProtocol {
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController
}

final class AlertControllerFactory: AlertFactoryProtocol {
    let userAction: UserAction
    let taskTitle: String?
    
    init(userAction: UserAction, taskTitle: String?) {
        self.userAction = userAction
        self.taskTitle = taskTitle
    }
    
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: userAction.title,
            message: "What do you want to do?",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alertController.textFields?.first?.text else { return }
            guard !task.isEmpty else { return }
            completion(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { [unowned self] textField in
            textField.placeholder = "Task"
            textField.text = taskTitle
        }
        
        return alertController
    }
}

// MARK: - UserAction
extension AlertControllerFactory {
    enum UserAction {
        case netTask
        case editTask
        
        var title: String {
            switch self {
            case .netTask:
                "New Task"
            case .editTask:
                "Edit Task"
            }
        }
    }
}
