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

// Kitura-Starter-Bluemix shows examples for creating custom routes.
import Foundation
import Kitura
import KituraSys
import KituraNet
import LoggerAPI
import HeliumLogger
import CFEnvironment
import SwiftyJSON

import InsightsForWeather
import NaturalLanguageClassifier
import RestKit

private let failure = { (error: RestError) in print(error) }

private let confidenceThreshold = 0.749

public enum WatsonError: ErrorProtocol {
    case invalidReturnURL
}

// All web apps need a Router instance to define routes
let router = Router()

// Using the HeliumLogger implementation for Logger
Log.logger = HeliumLogger()

// Serve static content from "public"
router.all("/static", middleware: StaticFileServer())

// Basic GET request
router.get("/hello") { _, response, next in
  response.headers["Content-Type"] = "text/plain; charset=utf-8"
  do {
    try response.status(.OK).send("Hello from Kitura-Starter-Bluemix! veh").end()
  } catch {
    Log.error("Failed to send response to client: \(error)")
  }
}

/**
 Gets the top class identifier based on the NLC training for the provided input text
 
 - parameter text:    text to classify
 - parameter success: returns the top class name
 */
private func getClassifyTopClass(text:String, success: (String -> Void) ) {
    
    let nlc = NaturalLanguageClassifier(username: Configuration.naturalLanguageClassifierUsername , password: Configuration.naturalLanguageClassifierPassword)
    nlc.classify(
        classifierId: Configuration.classifierID,
        text: text,
        failure: failure) { classify in
            
            var returnValue = ""
            print("Top class is \(classify.topClass) with confidence of \(classify.classes[0].confidence)")
            if (classify.classes[0].confidence > confidenceThreshold) {
                returnValue = String(classify.topClass)
            }
            success(returnValue)
    }
}

/**
 Gets the current temperature with the provided geocode
 
 - parameter geoCode: geocode to use as location lookup
 - parameter success: current temperature in sentence format
 */
private func getCurrentTemperature(geoCode:String, success: (String -> Void) ) {
    
    let insightsForWeather = InsightsForWeather(username: Configuration.weatherUsername, password: Configuration.weatherPassword)
    
    insightsForWeather.getCurrentForecast(
        units: "e",
        geocode: geoCode,
        language: "en-US",
        failure: failure) { forecast in
            
            guard let measurement = forecast.observation.measurement else {
                Log.error("Failed to get a proper measurement")
                return
            }
            let temp = String(" The current temperature in Austin is \(measurement.temp) F.")
            success(temp)
    }
}

/**
 Gets the current weather conditions for night and day based on the geocode provided
 
 - parameter geoCode: geocode to use as location lookup
 - parameter success: Returns day and night weather conditions
 */
private func getTodaysForecast(geoCode:String, success: (String -> Void) ) {
    
    let insightsForWeather = InsightsForWeather(username: Configuration.weatherUsername, password: Configuration.weatherPassword)
    
    insightsForWeather.get10DayForecast(
        units: "e",
        geocode: geoCode,
        language: "en-US",
        failure: failure) { forecast in
            
            let day = String(" Today: \(forecast.forecasts[0].day!.narrative)")
            let night = String(" Tonight \(forecast.forecasts[0].night!.narrative)")
            success(day + night)
    }
}

/**
 Retrieves the current conditions which is a collection of today's forcast and the current temperature
 
 - parameter geoCode: geocode to use as location lookup
 - parameter success: Returns day and night weather conditions along with and current temperature
 */
private func getConditions(geoCode:String, success: (String -> Void) ) {
    
    getCurrentTemperature(geoCode: geoCode) { temp in
        
        getTodaysForecast(geoCode: geoCode, success: { forecast in
            success(forecast + temp)
        })
    }
}

/**
 This will respond to a specific node in MIL slack
 
 - parameter response:      the text to present to slack
 - parameter requestDecode: There is specific information that slack sends for the request 
 so this object is the decode of that request
 TODO: There is more information to add at a later time I think
 
 - throws: <#throws value description#>
 */
private func respondToSlack(response:String, requestDecode:SlackRequest) throws {

    guard let serviceURL = requestDecode.responseURL else {
        throw WatsonError.invalidReturnURL
    }
    
    var json:JSON = [:]
    
    json[SlackItem.text.description()].string = response
    json[SlackItem.channelId.description()].string = requestDecode.channelId
    
    let localRequest = RestRequest(
        method: .POST,
        url: serviceURL,
        contentType: "application/json",
        messageBody: try json.rawData()
    )
    
    localRequest.responseJSON { response in
        switch response {
        case .success(let json):
            print(json)
        case .failure(let error):
            failure(error)
        }
    }
}

/**
 *  This is the entry point for requesting information from watson bot.  As NLC is trained more then 
 *  this bot will become more intelligent
 */
router.post("/askWatson") { request, response, next in
    
    var requestDecoded:SlackRequest?
    
    do {
        var readstring = try request.readString()
        requestDecoded = SlackRequest(payload: readstring!)
        guard let token = requestDecoded?.token else {
            try response.status(.forbidden).send("forbidden").end()
            next()
            return
        }
//        guard token == slackToken else {
//            try response.status(.forbidden).send("forbidden").end()
//            next()
//            return
//        }
    }catch {
        Log.error("Failed to send response \(error)")
    }
    
    if let requestDecoded = requestDecoded {
        do {
            let acknowledge = "Hi @\(requestDecoded.userName!)! I see you have a question. Let's see what I can find for you."
            try respondToSlack(response: acknowledge, requestDecode: requestDecoded)
            try response.status(.OK).end()
        } catch {
            Log.error("Failed to send response \(error)")
        }
        
        getClassifyTopClass(text: requestDecoded.text!) { topClass in
            
            do {
                var sendValue = ""
                switch(topClass) {
                case "temperature":
                    getCurrentTemperature(geoCode: Configuration.staticGeocode) { temperature in
                        sendValue = temperature
                    }
                case "conditions":
                    getConditions(geoCode: Configuration.staticGeocode) { weather in
                        sendValue = weather
                    }
                default:
                    sendValue  = "I'm currently not trained for this type of question"
                }
                Log.info("text from decode \(requestDecoded.text)")
                try respondToSlack(response: sendValue, requestDecode: requestDecoded)
                try response.status(.OK).end()
            } catch {
                Log.error("Failed to send response \(error)")
            }
            next()
        }
    }
}

/**
 *  Quick request for the temp bypassing NLC and hitting insights for weather directly
 */
router.get("/getTemp") { _, response, next in
    
    let insightsForWeather = InsightsForWeather(username: Configuration.weatherUsername, password: Configuration.weatherPassword)
    
    insightsForWeather.getCurrentForecast(
        units: "e",
        geocode: Configuration.staticGeocode,
        language: "en-US",
        failure: failure) { forecast in
        
        do {
            guard let measurement = forecast.observation.measurement else {
                Log.error("Failed to get a proper measurement")
                return
            }
            let temp = String(measurement.temp)
            try response.status(.OK).send(temp).end()
        } catch {
            Log.error("Failed to send response \(error)")
        }
    }
    next()
}

// Start Kitura-Starter-Bluemix server
do {
  let appEnv = try CFEnvironment.getAppEnv()
  let port: Int = appEnv.port
  let server = HTTPServer.listen(port: port, delegate: router)
  Server.run()
  Log.info("Server is started on \(appEnv.url).")
} catch CFEnvironmentError.InvalidValue {
  Log.error("Oops... something went wrong. Server did not start!")
}


