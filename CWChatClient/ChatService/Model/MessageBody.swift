//
//  MessageBody.swift
//  CWChatClient
//
//  Created by chenwei on 2017/10/2.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import Foundation

public protocol MessageBody: class {
    /// 消息类型
    var type: MessageType { get }
}
