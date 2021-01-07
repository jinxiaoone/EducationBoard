//
//  WRFileTableViewController.swift
//  WhiteBoard
//
//  Created by shiyu on 2021/1/7.
//  Copyright © 2021 jinxiao. All rights reserved.
//

import UIKit

protocol WRFileTableViewControllerDelegate: class {
    func selectedFile(fileUrl: String, pageCount: Int)
    func cancelSelect()
}


class WRFileTableViewController: UITableViewController {

    static let resuableIndentifer = "fileTableCell"

    weak var delegate: WRFileTableViewControllerDelegate?
    
    private var fileList: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "文件列表"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消",
                                                           style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: WRFileTableViewController.resuableIndentifer)
        
    }
    
    @objc func cancelButtonTapped(_: AnyObject) {
        delegate?.cancelSelect()
    }
    
    
    private func requestFileList() {
        
        
    }
    
    

    private func numberOfFiles() -> Int {
        return fileList?.count ?? 0
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfFiles()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WRFileTableViewController.resuableIndentifer, for: indexPath)

        if indexPath.row >= numberOfFiles() {
            return cell
        }
        if let fileInfo = fileList?[indexPath.row] as? NSDictionary {
            cell.textLabel?.text = (fileInfo["inputKey"] as! String)
        }
        return cell
    }

    
}
