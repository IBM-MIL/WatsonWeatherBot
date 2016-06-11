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

/**
 * Contains data for a Slack message
 * From https://api.slack.com/docs/attachments
*/
struct SlackMessageAttachment {
    
    /// A plain-text summary of the attachment.
    var fallback: String?
    /// An optional value that can either be one of good, warning, danger.
    var color: String?
    /// This is optional text that appears above the message attachment block.
    var pretext: String?
    /// Small text used to display the author's name.
    var author_name: String?
    /// A valid URL that will hyperlink the author_name text mentioned above.
    var author_link: String?
    /// A valid URL that displays a small 16x16px image to the left of the author_name text
    var author_icon: String?
    /// The title is displayed as larger, bold text near the top of a message attachment.
    var title: String?
    /// By passing a valid URL the title text will be hyperlinked
    var title_link: String?
    /// This is the main text in a message attachment, and can contain standard message markup
    var text: String?
    /// A valid URL to an image file that will be displayed inside a message attachment.
    var image_url: String?
    /// A valied URL to an image file that will be displayed as a thumbnail on the right side
    var thumb_url: String?
    /// Add some brief text to help contextualize and identify an attachment.
    var footer: String?
    /// To render a small icon beside your footer text, provide a URL string
    var footer_icon: String
    /// By providing the ts field the attachment will display an additional timestamp parameter.
    var ts: Int    
}
