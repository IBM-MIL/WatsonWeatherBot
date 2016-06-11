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

import Kitura
import KituraSys
import KituraNet
import LoggerAPI
import HeliumLogger
import CFEnvironment

Log.logger = HeliumLogger()

let weatherBot = WatsonWeatherBot()

do {
    let appEnv = try CFEnvironment.getAppEnv()
    let port: Int = appEnv.port
    let server = HTTPServer.listen(port: port, delegate: weatherBot.router)
    Server.run()
    Log.info("Server is started on \(appEnv.url).")
} catch CFEnvironmentError.InvalidValue {
    Log.error("Oops... something went wrong. Server did not start!")
}