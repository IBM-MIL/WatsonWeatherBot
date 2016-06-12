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

/**
 * Configuration settings for integration services
 */
public struct Configuration  {
    
    /// Latitude and longitude. ex. "30.401633699999998,-97.7143924"
    static let staticGeocode = ""
    
    /// Token assigned automatically from the 'Slash Commands' integration
    static let slackToken = ""
    
    /// Natural language classifier ID. You get this after training your classifier
    static let classifierID = ""
    
    /**
    * You can obtain the below information after your app has been deployed by 
    * running `cf env`
    */
    
    /// Username for Weather Insights service
    static let weatherUsername = ""
    
    /// Username for Weather Insights service
    static let weatherPassword = ""
    
    /// Username for Watson Natural Language Classifier service
    static let naturalLanguageClassifierUsername = ""
    
    /// Username for Watson Natural Language Classifier service
    static let naturalLanguageClassifierPassword = ""
    
  
    
}
