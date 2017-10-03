//
//  ConversationListController.swift
//  ChatKit
//
//  Created by chenwei on 2017/10/3.
//

import UIKit
import ChatClient

open class ConversationListController: UIViewController {

    public var chatManager = ChatClient.share.chatManager

    public var conversationList = [ConversationModel]()

    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.rowHeight = 64.0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        tableView.tableHeaderView = self.searchController.searchBar
        return tableView
    }()
    
    
    lazy var searchController: SearchController = {
        let searchController = SearchController(searchResultsController: self.searchResultController)
        searchController.searchResultsUpdater = self.searchResultController
        searchController.searchBar.placeholder = "搜索"
        searchController.searchBar.delegate = self
        searchController.showVoiceButton = true
        return searchController
    }()
    
    //搜索结果
    var searchResultController: SearchResultController = {
        let searchResultController = SearchResultController()
        return searchResultController
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        chatManager.addChatDelegate(self, delegateQueue: DispatchQueue.main)        
        setupUI()
    }

    func setupUI() {
        self.view.addSubview(self.tableView)
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "cell")
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UITableViewDelegate UITableViewDataSource
extension ConversationListController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteTitle = "删除"
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: deleteTitle) { (action:UITableViewRowAction, indexPath) in
            
            //获取当前model
            let conversationModel = self.conversationList[indexPath.row]
            //数组中删除
            self.conversationList.remove(at: indexPath.row)
            //从数据库中删除
            self.chatManager.deleteConversation(conversationModel.conversationId,
                                                deleteMessages: true)
            //删除
            self.tableView.deleteRows(at: [indexPath], with: .none)
        }
        
        let actionTitle = "标记已读"
        let moreAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: actionTitle) { (action:UITableViewRowAction, indexPath) in
            
            tableView.setEditing(false, animated: true)
        }
        return [deleteAction,moreAction]
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversationList[indexPath.row].conversation
        
        let chatVC = MessageController(conversation: conversation)
        chatVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversationList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationCell
        cell.conversationModel = conversationList[indexPath.row]
        return cell
    }
}


// MARK: - UISearchBarDelegate
extension ConversationListController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let message = "语言搜索"
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let alertAtion = UIAlertAction(title: "确定", style: .default) { (action) in
            
        }
        alertController.addAction(alertAtion)
        self.present(alertController, animated: true, completion: nil)
    }
}


extension ConversationListController: ChatManagerDelegate {
    
    public func didReceive(message: Message) {
        // 发送本地推送
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .background {
                
                
            } else {
                
                
            }
        }
    }
    
    public func conversationDidUpdate(_ conversation: Conversation) {
        
        /// 遍历所有会话 找到对应的index
        var unread = 0
        var index = -1
        for i in 0..<conversationList.count {
            let model = conversationList[i].conversation
            if model == conversation {
                index = i
                model.append(message: conversation.lastMessage)
            }
            unread += model.unreadCount
        }
        
        // 如果会话不存在 则加入刷新
        if index == -1 {
            let model = ConversationModel(conversation: conversation)
            conversationList.insert(model, at: 0)
        }
            // 如果是其他 则移动到第一个
            // TODO: isTop设置需要
        else if (index != 0) {
            let model = conversationList.remove(at: index)
            conversationList.insert(model, at: 0)
        }
        
        // 其他情况 如是第一个 直接刷新
        tableView.reloadData()
        if unread == 0 {
            self.tabBarItem.badgeValue = nil
        } else if (unread > 99) {
            self.tabBarItem.badgeValue = "99+"
        } else {
            self.tabBarItem.badgeValue = "\(unread)"
        }
        
    }
    
}



