# Watson Weather Bot

A [Kitura](https://github.com/IBM-Swift/Kitura) project which uses the [swift-watson-sdk](https://github.com/IBM-Swift/swift-watson-sdk) to create a Slack bot for grabbing current weather information.

## Requires:

 - [Open source Swift 3.0 - SNAPSHOT 05-03-a](https://swift.org/download/#snapshots)
 - [CF Command Line Interface](https://new-console.ng.bluemix.net/docs/starters/install_cli.html)
 
## Quick Start:

1. Clone the repository:

  `git clone https://github.com/IBM-MIL/WatsonWeatherBot/`

2. Follow the steps to get the [CF tool installed]((https://new-console.ng.bluemix.net/docs/starters/install_cli.html)) and logged in to your Bluemix account.

3. Create the required services:

  ```
  cf create-service weatherinsights Free weatherbot-weather
  cf create-service natural_language_classifier standard weatherbot-nlc
  ```
  
4. Deploy the app:

  `cf push`
  
5. Get the URL for your app and also credentials such as username and password from both weatherbot-weather and weatherbot-nlc

  `cf env`
  
  The complete VCAP information will be dumped to the screen. Record somewhere the username and passwords:
  
  ```
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
  
  ```
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
  
 6. Train the Natural Language Classifier:
 
 ```
 curl -u username:password -F training_data=@Training/weather_question_corpus.csv -F training_metadata="{\"language\":\"en\",\"name\":\"My Classifier\"}" "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers"
 ```

7. Record the classifier_id:
 
  After the training step, the classifier id will be returned in a message similar to this:

  ```
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

8. Create a new [Slack](https://slack.com/) team or use an existing one with admin priviledges:

9. Add new integrations to your Slack team

  Go to ***Add integrations*** in the settings. Then go to ***Manage***
  
  In Custom Integrations, add the following:
 
10. Add integration ***Slash Commands***:

 Use the following configuration:
 
 ```
 Command: `/weather`
  URL: `your URL goes here`
  Method: `POST`
  Token: this is not settable, record this to add to Configuration.swift
  Autocomplete help text:
     Description: `Get the weather`
     Usage hint: `What is the current temperature?`
 ```

11. Add integration ***Incoming Webhooks***:
  
 Use the following configuration:

 ```
 Post to Channel: choose a channel to post the weather information to
 Webhook URL: This is not settable, record this to later place in Configuration.swift
 ```
 
12. Modify Configuration.swift in Sources directory

 Open in your favorite editor Configuration.swift. All of these values need to be set.
 
 ```
 public struct Configuration  {
    
    static let classifierID = "replace this value with what you got in Step 7"
    static let staticGeocode = "30.401633699999998,-97.7143924" You can replace this with any longitude and latitude
    static let slackToken = "replace this with what you got in Step 10"
    static let slackIncomingWebhookURL = "replace this with what you got in Step 11"
    static let weatherUsername = "Replace this with what you got in Step 5"
    static let weatherPassword = "Replace this with what you got in Step 5"
    static let naturalLanguageClassifierUsername = "Replace this with what you got in Step 5"
    static let naturalLanguageClassifierPassword = "Replace this with what you got in Step 5"
}
```

13. Redeploy your app now with the Credentials set properly

 `cf push`
  
 The deployment of the app usually takes about 4-7 minutes to complete. Once it is finished, you should get a message like:
  
 ```
 1 of 1 instances running 

 App started
 ```
  
14. Type in your Slack channel: `/weather What are the current weather conditions?`

 If it worked properly, you should get a similar response:
 
 ```
 Today: Sunshine and a few afternoon clouds. High 91F. Winds SE at 5 to 10 mph. Tonight Partly cloudy. Low 71F. Winds SSE at 5 to 10 mph. The current temperature in Austin is 78 F.
 ```
 
