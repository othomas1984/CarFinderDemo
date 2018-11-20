# CarFinderDemo

## Installation

* Install pods if necessary (run `pod install` from the project directory).
* Get an API key from https://sandbox.amadeus.com/.
* Add a `Keys.plist` file to the root level of the project. Add a single entry in the plist with a key of `amadeusAPIKey`, and a String value of your key from Amadeus.
  - Note: This file is git ignored so it will not show up as a change in your repo.

## Usage
Car Finder allows users to find rental vehicles near by a given location. Either enter an address, or `use current location`, put in start/end dates (up to ~1 year from today), and tap search. Local rental options will be displayed in a sortable list (by company, distance or price). Tap a vehicle of interest to view further details and get directions to the rental company for pickup.
