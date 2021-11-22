//
//  ViewController.swift
//  Save to CloudKit
//
//  Created by Adsum MAC 1 on 22/11/21.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let database = CKContainer.default().privateCloudDatabase
    var notes = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       tableSetup()
        
        QueryDatabase()
    }

    @IBAction func addPostBTN(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Type Something", message: "what whould you like to save in a note?", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Type Note Here..."
        }
        
        let post = UIAlertAction(title: "Post", style: .default) { _ in
            guard let text = alert.textFields?.first?.text, text != "" else{
                self.popup(msg: "Please enter note to post it...😀")
                return
            }
            print(text)
            self.SaveToCloud(note: text)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(post)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func SaveToCloud(note:String){
        let newNote = CKRecord(recordType: "Note")
        newNote.setValue(note, forKey: "content")
        database.save(newNote) { record, error in
            guard error == nil else {
                self.popup(msg: "Oops!😯" + "\(error?.localizedDescription ?? "Something went wrong...")")
                return
            }
            guard record != nil else {
                self.popup(msg: "Oops!😯 Record is nil")
                return
            }
            self.QueryDatabase()
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.popup(msg: "Record succesfully saved...🎉")
             
            }
        }
    }
    
    func QueryDatabase(){
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                self.popup(msg: "Oops!😯" + "\(error?.localizedDescription ?? "Something went wrong...")")
                return
            }
            guard records != nil else {
                self.popup(msg: "Oops!😯 no record found")
                return
            }
            guard records?.count != 0 else {
                self.popup(msg: "Oops!😯 no record found")
                return
            }
            self.notes = records!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - Table view setup
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableSetup(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.notes[indexPath.row].value(forKey: "content") as? String
        return cell
    }
}

// MARK: Message Popup
extension UIViewController{
    func popup(msg:String){
        DispatchQueue.main.async {
            let alertpopup = UIAlertController(title: "", message: msg, preferredStyle: .alert)
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.dismissAlert(timer:)), userInfo: nil, repeats: false)
            self.present(alertpopup, animated: true, completion: nil)
        }
    }
    
    @objc func dismissAlert(timer:Timer){
        self.dismiss(animated: true, completion: nil)
        timer.invalidate()
    }
    
}
