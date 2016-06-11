/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import SwiftyJSON

public enum SlackItem {
    case token
    case teamId
    case teamDomain
    case channelId
    case channelName
    case userId
    case userName
    case command
    case text
    case responseURL
    
    /// Represent the voice as a `String`.
    public func description() -> String {
        switch self {
        case token: return "token"
        case teamId: return "team_id"
        case teamDomain: return "team_domain"
        case channelId: return "channel_id"
        case channelName: return "channel_name"
        case userId: return "user_id"
        case userName: return "user_name"
        case command: return "command"
        case text: return "text"
        case responseURL: return "response_url"
        }
    }
}

public struct SlackRequest {
    
    public var token:String?
    
    public var teamId:String?
    
    public var teamDomain:String?
    
    public var channelId:String?
    
    public var channelName:String?
    
    public var userId:String?
    
    public var userName:String?
    
    public var command:String?
    
    public var text:String?
    
    public var responseURL:String? = ""
    
    public init(payload:String) {
        
        // use removingPercentEncoding on the string once that functionality is available in swift 3
        // foundations
        
        let elementPairs = payload.components(separatedBy: "&")
        //
        for element in elementPairs {
            print(element)
            let elementItem = element.components(separatedBy: "=")
            
            switch elementItem[0] {
            case SlackItem.token.description():
                token = elementItem[1]
            case SlackItem.teamId.description():
                teamId = elementItem[1]
            case SlackItem.teamDomain.description():
                teamDomain = elementItem[1]
            case SlackItem.channelId.description():
                channelId = elementItem[1]
            case SlackItem.channelName.description():
                channelName = elementItem[1]
            case SlackItem.userId.description():
                userId = elementItem[1]
            case SlackItem.userName.description():
                userName = elementItem[1]
            case SlackItem.command.description():
                command = elementItem[1]
            case SlackItem.text.description():
                text = elementItem[1]
            default:
                break
            }
        }
    }
}
















