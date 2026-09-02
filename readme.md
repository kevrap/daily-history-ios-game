
Submitted by: Kevin Rapkin

# On This Day

## Table of Contents

1. [Overview](#Overview)
2. [Demos](#Demos)
3. [Schema](#Schema)

## Overview

### Description
**On This Day** is an iOS daily history game inspired by Wordle, built with Swift and SwiftUI. Each day, the app fetches a random historical event for the current date from the On This Day API and challenges players to guess the 4-digit year it occurred in, using a numeric keypad, within six tries. After each guess, the grid updates with color feedback. On a win, players can copy an summary of their performance to share.

User accounts are handled through Firebase Authentication, letting players log in or sign up with email and password, while Firestore stores statistics on games played, average guesses, and win rate for the current day so users can compare their performance against everyone else playing that day.

## Demos

**Progress Demo 1**

<img src="final_progress_demo_1.gif" alt="progress demo 1" width="50%" />

**Progress Demo 2**

<img src="final_progress_demo_2.gif" alt="progress demo 2" width="50%" />

**Final Demo Video**

[Click here for YouTube Demonstration Video](https://youtu.be/u5BBl82nebk)

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
