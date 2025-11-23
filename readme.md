
Submitted by: Kevin Rapkin ZNumber: Z15183142


Original App Design Project - README Template
===

# On This Day

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

[Provide a brief description of your app, its purpose, and functionality.]

### App Evaluation

[Evaluation of your app across the following attributes]
- **Category:** [e.g., Social, Entertainment, Education]
- Game
- **Mobile:** [Is it a mobile application only?]
- Uses mobile touch screen functionality to be more accessible than typical website. Although it could also be recreated as a website with less functionality.
- **Story:**  [What story does your app tell?]
- The app combines a love for history, trivia, and a friendly competition of a guessing game. Users will be able to compete with their friends and learn about history and new trivia facts at the same time. People should love to use it.
- **Market:** [Target audience for the app]
- There are a lot of people who like trivia and also playing Worldle-like games. This targets that niche group who will be excited. 
- **Habit:** [Is it a daily use app or occasional use?]
- Yes, it allows for a daily play for people. But they can play repetively too. 
- **Scope:** [Is it a broad or narrow app in terms of features?]
- It's scope is possible to achieve satisfactorily before the end of the semester. But it is also scalable and more features could be added to make it even better if time allows.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can launch the app to the game screen that displays a historical blurb from an "on this day" API
* Users are instructed to enter the year they believe this day in history happened
* Users are given up to six chances to get the year right, with color-coded feedback based on their response to see how close they are
* When the user gets the right answer, they are congratulated and offered to play again

**Optional Nice-to-have Stories**

* User's scores are collected and stored in a database for that day so everyone can see how people are performing on average
* Users can see their performance compared with global averages

### 2. Screen Archetypes

- [ ] Game Screen
* Required User Feature: 
* Shows historal blurb for the day and gives instructions
* Has tile grid to show guesses
* Has easy way to enter four digit year
* Has color coded feedback for user guesses
* Has option to view stats screen at any time
* User can refresh to replay a different game any time
* On game complete user can tap a button to copy a block of text that shows their performance in the game
- [ ] Stats Screen
* Shows global average statistics for game
* Shows current user statistics for comparison
* Statistics include things like win rate, guess number, etc.

### 3. Navigation

**Tab Navigation** (Tab to Screen)


- [ ] Game Screen
    - [ ] Shows the game screen
- [ ] Stats Screen
    - [ ] Shows the stats screen

**Flow Navigation** (Screen to Screen)

- [ ] Game Screen
  * leads to Stats Screen
- [ ] Stats Screen
  * leads back to Game Screen


## Wireframes

[Add picture of your hand sketched wireframes in this section]

### [BONUS] Digital Wireframes & Mockups

![image](https://hackmd.io/_uploads/BkNQ1ZgZ-g.png)

![image2](https://hackmd.io/_uploads/BkcOJWe-Wx.png)



## Schema 


### Models

[Event]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| id | String | unique id    |
| date | String | date of event     |
| year     | int   | numerical year
| desc     | String    | historical event description from API

[Game Result]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| id | String | unique id    |
| date | String | date of game    |
| correctyear     | int   | correct guess year
| guesses   | int   | number of guesses
| didWin | bool | whether user won 



### Networking

- [List of network requests by screen]
- External API: On This Day Events (Wikipedia-backed)
Base: https://byabbe.se/on-this-day/
- .GET https://byabbe.se/on-this-day/{month}/{day}/events.json

- Firebase Firestore: Global Stats
Collection: dailyStats
Document ID: YYYY-MM-DD (today’s date)
