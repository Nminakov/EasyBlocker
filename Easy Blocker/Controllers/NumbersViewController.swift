//
//  NumbersViewController.swift
//  Easy Blocker
//
//  Created by Nikita Minakov on 12/26/20.
//

import UIKit
import CallKit

class NumbersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var fileUrl: URL? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.studio.devlav.easy-blocker")?.appendingPathComponent("numbers")
        return url
    }
    
    private var numbers: [NumberEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    private func reloadData() {
        self.numbers = loadList()
        self.tableView.reloadData()
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "studio.devlav.easy-blocker.easy-blocker-ext") { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    @IBAction func onAdd(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Добавление номера",
            message: "Введите номер для добавления в БД",
            preferredStyle: .alert
        )
        alertController.addTextField { (textField) in
            textField.placeholder = "+7 000 000 00 00"
            textField.keyboardType = .phonePad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alertController.textFields?.first?.text, let number = Int(text) {
                self.numbers.append(NumberEntry(number: number))
                self.saveList()
                self.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func loadList() -> [NumberEntry] {
        guard
            let path = fileUrl?.path else {
            return []
        }
        
        if
            FileManager.default.fileExists(atPath: path),
            let data = FileManager.default.contents(atPath: path)
        {
            do {
                let numbers = try JSONDecoder().decode([NumberEntry].self, from: data)
                return numbers
            }
            catch {
                print(error)
            }
        }
        return []
    }

    private func saveList() {
        guard
            let path = fileUrl?.path else {
            return
        }
        
        do {
            let data = try JSONEncoder().encode(self.numbers)
            FileManager.default.createFile(atPath: path, contents: data)
        }
        catch {
            print(error)
        }
    }
    
}

extension NumbersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "\(numbers[indexPath.row].number)"
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "DEL") { [weak self]_ , _, handler in
            handler(true)
            self?.numbers.remove(at: indexPath.row)
            self?.saveList()
            self?.reloadData()
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
