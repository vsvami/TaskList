//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Vladimir Dmitriev on 04.04.24.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    private var storageManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }

    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchData() {
        storageManager.fetchData { [unowned self] result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskName: String) {
        storageManager.create(taskName) { [unowned self] task in
            taskList.append(task)
            tableView.insertRows(
                at: [IndexPath(row: self.taskList.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
    
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor.milkBlue
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    // Edit task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete task
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            storageManager.delete(task)
        }
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    private func showAlert(task: ToDoTask? = nil, completion: (() -> Void)? = nil) {
        let alertFactory = AlertControllerFactory(
            userAction: task != nil ? .editTask : .netTask,
            taskTitle: task?.title
        )
        let alert = alertFactory.createAlert { [unowned self] taskName in
            if let task, let completion {
                storageManager.update(task, newName: taskName)
                completion()
                return
            }
            save(taskName)
        }
        present(alert, animated: true)
    }
}
