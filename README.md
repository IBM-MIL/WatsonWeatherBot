# Watson Weather Bot

A [Kitura](https://github.com/IBM-Swift/Kitura) project which uses the [swift-watson-sdk](https://github.com/IBM-Swift/swift-watson-sdk) to create a Slack bot for grabbing current weather information.

## Prerequisites:

1. Install [Open source Swift 3.0 - SNAPSHOT 05-03-a](https://swift.org/download/#snapshots), making sure to [update your `$PATH`](https://swift.org/getting-started/#installing-swift). 

2. Install the [Cloud Foundry CLI interface](https://github.com/cloudfoundry/cli#downloads).

3. Register for a [Bluemix account](https://console.ng.bluemix.net/registration/). We will be using two services from BlueMix for this application:
  * The [Natural Language Classifier](http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/nl-classifier.html) service interprets the intent behind the queries to the bot, and will return a classification corresponding to the nature of the query.
  * [Insights for Weather](https://console.ng.bluemix.net/catalog/services/insights-for-weather) enables you to integrate real-time or historical data into your applications.

4. Have a Slack team with admin privileges ready, or create a new [Slack](https://slack.com/) team.


## Quick Start:

1. Clone the Watson Weather repository from a directory you'd like to store the bot:

  `git clone https://github.com/IBM-MIL/WatsonWeatherBot/`

2. Copy the Configuration-Sample.swift file to Sources/Configuration.swift

 `cp Configuration-Sample.swift Sources/Configuration.swift`

3. If you haven't already, login to BlueMix. To do so, set the API endpoint and then login to your account.

 ```bash
 cf api https://api.ng.bluemix.net
 cf login
 ```

4. Create the services the Bot uses: Weather Insights and Natural Language Classifier.

 > Note that you will receive a warning that the Natural Language Classifier incurs a cost. As of the time this bot was created, a starter level of usage is included at not cost. For more details, see the [NLC pricing](http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/nl-classifier.html#pricing-block).

 ```bash
 cf create-service weatherinsights Free weatherbot-weather
 cf create-service natural_language_classifier standard weatherbot-nlc
 ```
 
5. Deploy the app from your local environment to BlueMix. There will be a delay of several minutes to install the system dependencies, download app dependencies, and compile the application.

 `cf push`
 
6. Get the URL for your app and also credentials such as username and password from both weatherbot-weather and weatherbot-nlc

 `cf env WatsonWeatherBot`
  
 The complete VCAP information will be dumped to the screen. Record somewhere the username and passwords:
  
 ```javascript
  "weatherinsights": [
   {
    "credentials": {
     "host": "twcservice.mybluemix.net",
     "password": "password appears here",
     "port": 443,
     "url": "url appears here",
     "username": "user appears here"
    },
    "label": "weatherinsights",
    "name": "weatherbot-weather",
    "plan": "Free",
    "tags": [
     "big_data",
     "ibm_created",
     "ibm_dedicated_public"
    ]
   }
  ]
 ```
  
 Record the URIs that appears for your deployment:
  
 ```javascript
  "name": "WatsonWeatherBot",
  "space_id": "f900a490-dbd5-4053-abe2-c7645e3527eb",
  "space_name": "Swift",
  "uris": [
   "watsonweatherbot-posttympanic-marathon.mybluemix.net"
  ],
  "users": null,
  "version": "dfa2cccf-8990-4dc4-9a0b-876579beae29"
 }
 ```
 
7. Train the Natural Language Classifier. 
 
 During this process, you seed the classifier with some strings and corresponding classifications. A training set is provided in `Training/weather_question_corpus.csv`. Note that it may take several minutes for the training process to complete.
 
 Replace username:password below with the credentials from the `natural_language_classifier` section of `VCAP_SERVICES` you recorded in the previous step.
 
  ```bash
  curl -u username:password -F training_data=@Training/weather_question_corpus.csv -F training_metadata="{\"language\":\"en\",\"name\":\"My Classifier\"}" "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers"
  ```

7. Record the `classifier_id`. After the training step, it will be returned in a message similar to this:

  ```javascript
 {
  "classifier_id" : "classifier id appears here",
  "name" : "My Classifier",
  "language" : "en",
  "created" : "2016-06-10T15:14:49.322Z",
  "url" : "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/classifier id",
  "status" : "Training",
  "status_description" : "The classifier instance is in its training phase, not yet ready to accept classify requests"
 }%
 ```

8. Add ***Slash Command*** integration to your Slack team. 

 From `https://<TEAM-NAME>.slack.com/apps`, search for the ***Slash Commands*** integration.

 Use the following configuration:
 
 ```
 Command: `/weather`
  URL: `URL to WatsonWeatherBot service recorded when calling cf env. Use an https:// prefix`
  Method: `POST`
  Token: this is not settable, record this to add to Configuration.swift
  Autocomplete help text: Select the box
     Description: `Get the weather`
     Usage hint: `What is the current temperature?`
 ```
 
9. Modify Configuration.swift in `Sources` directory

 Open in your favorite editor Configuration.swift. All of these values need to be set.
 
 ```Swift
 public struct Configuration  {
    
    static let staticGeocode = "37.7839,122.4012" You can replace this with any longitude and latitude
    static let slackToken = "replace this with what you got in Step 9"
    static let classifierID = "replace this value with what you got in Step 8"
    static let weatherUsername = "Replace this with what you got in Step 6"
    static let weatherPassword = "Replace this with what you got in Step 6"
    static let naturalLanguageClassifierUsername = "Replace this with what you got in Step 6"
    static let naturalLanguageClassifierPassword = "Replace this with what you got in Step 6"
}
```

10. Redeploy your app now with the Credentials set properly

 `cf push`
  
 The deployment of the app usually takes about 4-7 minutes to complete. Once it is finished, you should get a message like:
  
 ```
 1 of 1 instances running 

 App started
 ```
  
11. Type in your Slack channel: `/weather What are the current weather conditions?`

 If it worked properly, you should get a similar response:
 
 ```
 Today: Sunshine and a few afternoon clouds. High 91F. Winds SE at 5 to 10 mph. 
 Tonight Partly cloudy. Low 71F. Winds SSE at 5 to 10 mph. 
 The current temperature in San Francisco is 78 F.
 ```
