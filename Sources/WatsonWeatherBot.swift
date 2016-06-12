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
import Kitura
import LoggerAPI


class WatsonWeatherBot {

    let router: Router = Router()

    init() {
        router.get("/temperature", handler: handleTemperature)
        router.post("/askWatson", handler: handleAskWatson)
    }

    private func handleAskWatson(request: RouterRequest,
                                 response: RouterResponse, next: () -> Void ) {

        do {
            let requestData = try request.readString()

            guard let readString = requestData else {
                try response.status(.badRequest).end()
                return
            }

            let requestDecoded = SlackRequest(payload: readString)

            guard let token = requestDecoded.token else {
                Log.warning("Slack sent request without a token")
                try response.status(.forbidden).send("forbidden").end()
                next()
                return
            }

            guard token == Configuration.slackToken else {
                Log.warning("Slack sent a request with an invalid token")
                try response.status(.forbidden).send("forbidden").end()
                next()
                return
            }

            getClassifyTopClass(text: requestDecoded.text!) { topClass in

                do {
                    var sendValue = ""
                    switch topClass {
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
                    try response.status(.OK).send(sendValue).end()
                } catch {
                    Log.error("Failed to send response \(error)")
                }
                next()
            }

        } catch {
            Log.error("Failed to send response \(error)")
        }
    }

    private func handleTemperature(request: RouterRequest,
                                   response: RouterResponse, next: () -> Void ) {

        getCurrentTemperature(geoCode: Configuration.staticGeocode) {

            temperature in

            do {
                try response.status(.OK).send(temperature).end()
            } catch {
                Log.error("Failed to send response")
            }

            next()
        }

    }

}
