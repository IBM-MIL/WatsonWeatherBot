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

import InsightsForWeather
import NaturalLanguageClassifier
import RestKit

import LoggerAPI

private let failure = { (error: RestError) in print(error) }

/// The natural language classifier must have the following confidence score to respond.
private let confidenceThreshold = 0.749

enum WatsonError: ErrorProtocol {
    case invalidReturnURL
}

/**
 Gets the top class identifier based on the NLC training for the provided input text

 - parameter text:    text to classify
 - parameter success: returns the top class name
 */
public func getClassifyTopClass(text: String, success: (String -> Void) ) {

    let nlc = NaturalLanguageClassifier(username: Configuration.naturalLanguageClassifierUsername,
                                        password: Configuration.naturalLanguageClassifierPassword)

    nlc.classify(
        classifierId: Configuration.classifierID,
        text: text,
        failure: failure) { classify in

            var returnValue = ""
            if classify.classes[0].confidence > confidenceThreshold {
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
public func getCurrentTemperature(geoCode: String, success: (String -> Void) ) {

    let insightsForWeather = InsightsForWeather(username: Configuration.weatherUsername,
                                                password: Configuration.weatherPassword)

    insightsForWeather.getCurrentForecast(
        units: "e",
        geocode: geoCode,
        language: "en-US",
        failure: failure) { forecast in

            guard let measurement = forecast.observation.measurement else {
                Log.error("Failed to get a proper measurement")
                return
            }

            let temp = String("The current temperature in San Francisco is \(measurement.temp) F.")

            success(temp)
    }
}

/**
 Gets the current weather conditions for night and day based on the geocode provided

 - parameter geoCode: geocode to use as location lookup
 - parameter success: Returns day and night weather conditions
 */
public func getTodaysForecast(geoCode: String, success: (String -> Void) ) {

    let insightsForWeather = InsightsForWeather(username: Configuration.weatherUsername,
                                                password: Configuration.weatherPassword)

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
 Retrieves the current conditions which is a collection of today's forcast
 and the current temperature

 - parameter geoCode: geocode to use as location lookup
 - parameter success: Returns day and night weather conditions along with and current temperature
 */
public func getConditions(geoCode: String, success: (String -> Void) ) {

    getCurrentTemperature(geoCode: geoCode) { temp in

        getTodaysForecast(geoCode: geoCode, success: { forecast in
            success(forecast + temp)
        })
    }
}
