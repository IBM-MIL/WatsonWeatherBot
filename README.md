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
