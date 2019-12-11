//
//  KKSandboxUIViewController.swift
//  KKSandboxUI
//
//  Created by 王铁山 on 2017/8/23.
//  Copyright © 2017年 king. All rights reserved.
//

import UIKit

/// 列表界面
open class KKSandboxUIViewController: UITableViewController {
    
    open var rootPath: String
    
    open var component: String?
    
    open var fullPath: String {
        return self.rootPath + (component == nil ? "" : "/\(component!)")
    }
    
    open var showTitle: String {
        return component == nil ? (self.rootPath as NSString).lastPathComponent : component!
    }
    
    open var files: [KKSandboxFileModel] = []
    
    public init(rootPath: String, component: String?) {
        self.rootPath = rootPath
        self.component = component
        super.init(nibName: nil, bundle: nil)
    }
    
    public init() {
        self.rootPath = NSHomeDirectory()
        self.component = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.tableFooterView = UIView()
        
        self.title = self.showTitle
        
        self.setNativationBar()
        
        self.files = KKSandboxHelper.fileModelAtPath(directory: self.fullPath)
            
        self.tableView.reloadData()
    }
    
    open func setNativationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addDirectory))
        let navigationBar: UINavigationBar? = self.navigationController?.navigationBar
        navigationBar?.tintColor = UIColor.black
        navigationBar?.barTintColor = UIColor.white
        if self.navigationController?.viewControllers.first == self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: KKSandboxHelper.getLocalizedString(name: "Cancel"),
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(dismissAction))
        }
    }
    
    @objc open func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addDirectory() {
        
        let ac: UIAlertController = UIAlertController.init(title: KKSandboxHelper.getLocalizedString(name: "CreateDirectory"),
                                                           message: nil, preferredStyle: .alert)
        
        ac.addTextField { (tf) in
            tf.placeholder = KKSandboxHelper.getLocalizedString(name: "CreateDirectoryPlaceHolder")
        }
        
        ac.addAction(UIAlertAction.init(title: KKSandboxHelper.getLocalizedString(name: "Cancel"), style: .cancel, handler: { (action) in
            
        }))
        
        ac.addAction(UIAlertAction.init(title: KKSandboxHelper.getLocalizedString(name: "Create"), style: .default, handler: { [weak ac] (action) in
            
            guard let tf: UITextField = ac?.textFields?.first else {
                return
            }
            guard let text = tf.text, !text.isEmpty else { return }
            
            do {
                
                let fullPath: String = self.fullPath.appending("/").appending(text)
                
                try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
                
                let model = KKSandboxHelper.getFileModel(name: text, path: fullPath)
                
                model.fileType = .directory
                
                self.files.insert(model, at: 0)
                
                self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
                
            } catch {
                
            }
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    open func openFile(file: KKSandboxFileModel) {
        let path = file.path
        switch file.fileType {
        case .image:
            if let img = UIImage.init(contentsOfFile: path) {
                self.navigationController?.pushViewController(KKSandboxImageController.init(image: img), animated: true)
            }
        case .array, .text, .dictionary:
            var obj: String?
            if file.fileType == .dictionary {
                guard let content = NSDictionary.init(contentsOfFile: path) else { return }
                guard let data = (try? JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)) else { return }
                guard let str = String.init(data: data, encoding: .utf8) else { return }
                obj = str
            } else if file.fileType == .array {
                guard let content = NSArray.init(contentsOfFile: path) else { return }
                guard let data = (try? JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)) else { return }
                guard let str = String.init(data: data, encoding: .utf8) else { return }
                obj = str
            } else if file.fileType == .text {
                obj = try? String.init(contentsOfFile: path)
            }
            guard let object = obj else { return }
            self.navigationController?.pushViewController(KKSandboxTextController.init(text: object), animated: true)
        case .directory:
            let new = KKSandboxUIViewController.init(rootPath: self.fullPath, component: file.name)
            self.navigationController?.pushViewController(new, animated: true)
        default:
            break
        }
    }
    
    // MARK: - Table view data source
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cellId")
        }
        cell?.accessoryType = .detailDisclosureButton
        let model = self.files[indexPath.row]
        cell?.imageView?.image = model.getIconImage()
        cell?.imageView?.contentMode = .scaleToFill
        cell?.textLabel?.text = model.name
        cell?.detailTextLabel?.text = model.fileSize
        return cell!
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openFile(file: self.files[indexPath.row])
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.files[indexPath.row].isDeleteable
    }
    
    open override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard indexPath.row < self.files.count else { return }
            let model: KKSandboxFileModel = self.files[indexPath.row]
            let path: String = model.path
            do {
                try FileManager.default.removeItem(atPath: path)
                self.files.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let model = self.files[indexPath.row]
        guard UserDefaults.standard.value(forKey: "com.kksandboxui.hint") as? String != "true" else {
            self.share(model: model)
            return
        }
        UserDefaults.standard.setValue("true", forKey: "com.kksandboxui.hint")
        UserDefaults.standard.synchronize()
        let vc = UIAlertController.init(title: KKSandboxHelper.getLocalizedString(name: "Hint"), message: KKSandboxHelper.getLocalizedString(name: "ShareHint"), preferredStyle: .alert)
        vc.addAction(UIAlertAction.init(title: KKSandboxHelper.getLocalizedString(name: "Know"), style: .default, handler: { [weak self] (action) in
            self?.share(model: model)
        }))
        
        self.present(vc, animated: true, completion: nil)
    }
    
    open func share(model: KKSandboxFileModel) {
        let share = UIActivityViewController.init(activityItems: [URL.init(fileURLWithPath: model.path)], applicationActivities: nil)
        self.present(share, animated: true, completion: nil)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

/// 图片预览控制器
class KKSandboxImageController: UIViewController {
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "图片预览"
        
        self.view.backgroundColor = UIColor.gray
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64))
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.image = self.image
        
        self.view.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 文本预览控制器
class KKSandboxTextController: UIViewController {
    
    var text: String
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "文本预览"
        
        self.view.backgroundColor = UIColor.gray
        
        let textView = UITextView.init(frame: self.view.bounds)
        
        textView.isEditable = false
        
        textView.text = self.text
        
        self.view.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







