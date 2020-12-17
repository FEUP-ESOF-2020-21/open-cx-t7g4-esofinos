# openCX-InstantWords Development Report

Welcome to the documentation pages of the InstantWords of **openCX**!

You can find here detailed about the (sub)product, hereby mentioned as module, from a high-level vision to low-level implementation decisions, a kind of Software Development Report (see [template](https://github.com/softeng-feup/open-cx/blob/master/docs/templates/Development-Report.md)), organized by discipline (as of RUP): 

* Business modeling 
  * [Product Vision](#Product-Vision)
  * [Elevator Pitch](#Elevator-Pitch)
* Requirements
  * [Use Case Diagram](#Use-case-diagram)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
* Architecture and Design
  * [Logical architecture](#Logical-architecture)
  * [Physical architecture](#Physical-architecture)
  * [Prototype](#Prototype)
* [Implementation](#Implementation)
* [Test](#Test)
* [Configuration and change management](#Configuration-and-change-management)
* [Project management](#Project-management)

So far, contributions are exclusively made by the initial team, but we hope to open them to the community, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us! 

Thank you!

Daniel Garcia Silva *up201806524@fe.up.pt*

Gonçalo Alves *up201806451@fe.up.pt*

Inês Silva *up201806385@fe.up.pt*

Pedro Seixas *up201806227@fe.up.pt*

José Silva *up201705591@fe.up.pt*

---

## Product Vision

Enabling everyone, specially people with hearing disabilities, to experience conferences to the fullest by using speech-to-text to create real time subtitles during talks!

---
## Elevator Pitch

Conferences are great way of sharing knowledge, sadly not everyone can enjoy them equally. Hearing problems and the language barrier are a major turndown for lots of users. As most of the organized conferences don't have the access to a captioner, we created InstantWords. Our app makes use of Speech-To-Text technology, providing transcripts directly to your phone, in a wide array of languages, and enabling a brand new audience to enjoy their favourite conferences.

---
## Requirements

### Use case diagram 

![Use Case Diagram](https://i.imgur.com/64q1OHj.png)


#### Register/Login

* **Actor**: User.
* **Description**: The User can register in the app.
* **Preconditions and Postconditions**: For Register, there are none. For Login, must have a previously registered account.

* **Normal Flow**: 
    i. The user registers in the app by choosing a username, email and a password.
    
* **Alternative Flows and Exceptions**: When registering, if the password is considered weak (has less than 8 characters), a pop-up message will alert the user of this event and block him from creating an account with those credentials. When logging in, if the user tries to login with invalid credentials, wether it be the username or the password, a pop up message, similar to that described above, is displayed alerting of this event.

#### View List of Conferences

* **Actor**: User.
* **Description**: The User can view the list of conferences.
* **Preconditions and Postconditions**: The User must be registered within the app.

* **Normal Flow**:
    i. The User, after logging in/registering enters the dashboard and can view a list of conferences.
    
* **Alternative Flows and Exceptions**: 
    ia.The User can go to his profile, by clicking his profile picture, and can view his attended and created conferences.
    ib. The User can use the search bar, in the dashboard, to filter the list of conferences.

#### Add Conference

* **Actor**: Speaker.
* **Description**: The Speaker can add a conference, by choosing his speech language.
* **Preconditions and Postconditions**: The User must be registered within the app.

* **Normal Flow**:
    i. The Speaker, after logging in/registering enters the dashboard and has an option to add a conference.
    ii. A new window will appear requesting the conference's name and speech language.
    
* **Alternative Flows and Exceptions**: If the Speaker tries to create a conference with a name that already exists or with no language, a pop up message will appear, alerting the user to this event and blocking him from doing so.


#### Get a transcript of my speech

* **Actor**: Speaker.
* **Description**: The Speaker can view the transcript of his speech.
* **Preconditions and Postconditions**: The Speaker must be registered within the app and have created a conference.

* **Normal Flow**:
    i. The Speaker, after creating a conference goes to a new window where he can speak, by clicking in the microphone button.
    ii. After speaking a few words, the Speaker can see the transcript of his speech in the screen.
    
* **Alternative Flows and Exceptions**: 
   ia. The Speaker, when in his profile page, can click on one of his created conferences, sending him to the conference window described above.

#### Get a transcript of the speech in my language

* **Actor**: Spectator.
* **Description**: The Spectator can view the transcript of a speech, in a language of his choosing.
* **Preconditions and Postconditions**: The Spectator must be registered within the app and must have chosen a conference to attend.

* **Normal Flow**:
    i. The Spectator, after selecting a conference to attend in his dashboard, goes to a new window where he can choose the language of the transcript, from a dropdown list.
    ii. After choosing a language, the Spectator can see the transcript of the speech in the screen, translated in that language.
    
* **Alternative Flows and Exceptions**:
   ia. The Spectator, when in his profile page, can click on one of his attended conferences, sending him to the conference window described above.

### User stories

#### User Story Map

![User Story Map](https://i.imgur.com/uGvfUe4.png)

#### Story #1 **EPIC**

As a spectator, I want a transcript, so that I can read what is being said in the conference.

**Mockup**

![Conference Transcript](https://i.imgur.com/OGJxRMK.png)

**Acceptance Tests**
```gherkin
Given I want the transcript of the current talk,
When I select it on the app,
Then I can read what is being said.
```

**Value:** Must have

**Effort:** XL

---- 

#### Story #2

As a spectator, I want to attend conferences in any language, so that I have more options to attend.

**Mockup**

![Language Search](https://i.imgur.com/c14bkOT.png)


**Acceptance Tests**
```gherkin
Given I want to understand what is being said,
When I attend a conference in any language,
Then I have more options of conferences to attend.
```

**Value:** Must have

**Effort:** M

---

#### Story #3

As a spectator, I want to select the transcript language, so that I can read what is being said in my desired language.

**Mockup**

![Conference Transcript](https://i.imgur.com/OGJxRMK.png)

**Acceptance Tests**
```gherkin
Given I want to select the transcript language,
When I attend a conference,
Then I can read what is being said in my desired language.
```

**Value:** Must have

**Effort:** XL

---

#### Story #4

As a speaker, I want to be able to select my speech language.

**Mockup**

![Speaker Language Select](https://i.imgur.com/5xAZGas.png)

**Acceptance Tests**
```gherkin
Given I want to be able to select my language,
When I start the conference,
Then the spectators know which language I am speaking.
```

**Value:** Must have

**Effort:** M

---

#### Story #5

As an user, I want to be able to create my own account, so that I can use the app.

**Mockup**

![Main Menu](https://i.imgur.com/1vmbEy5.png)

**Acceptance Tests**
```gherkin
Given I want to be able to create my own account,
When I use the app,
Then I can save my preferences.
```

**Value:** Should have
**Effort:** M

---

#### Story #6

As a spectator, I want to be able to search for talks/conferences, in order to join them.

**Mockup**

![Spectator Main Menu](https://i.imgur.com/vTkurLw.png)

**Acceptance Tests**
```gherkin
Given I want to search for talks/conferences,
When I´m using the app
Then I can join the talks/conferences.
```

**Value:** Could have

**Effort:** S

---

#### Story #7

As a specator, I want to be able to scan a talk/workshop QR code, so that I can join it directly.

**Mockup**

![QRCode](https://i.imgur.com/zBhBekv.png)


**Acceptance Tests**
```gherkin
Given I want to be able to scan a talk/worlshop QR code,
When I'm attending one,
Then I can join it directly.
```

**Value:** Should have

**Effort:** L

---

#### Story #8

As an user, I want to track which conferences I attended and planned to attend, so that I can organize my schedule.

**Mockup**

![User Conferences](https://i.imgur.com/3zXCNJD.png)

**Acceptance Tests**
```gherkin
Given I want to track which conferences I attended and plan to attend,
When I'm using the app,
Then I can organize my schedule.
```

**Value:** Could have

**Effort:** M

---

#### Story #9

As an user, I want to be able to logout, so that I can share my device with other people.

**Mockup**

![User Logout](https://i.imgur.com/tpdq9v6.png)

**Acceptance Tests**
```gherkin
Given I want to be able to logout,
When I'm logged in the app,
Then I can share my device with other people.
```

**Value:** Should have

**Effort:** S

---

#### Story #10

As a speaker, I want to be able to create a talk, so that spectators can join.

**Mockup**

![Speaker Main Menu](https://i.imgur.com/Jr3FpDh.png)

**Acceptance Tests**
```gherkin
Given I want to be able to create a talk,
When I'm speaking at a conference,
Then Spectators can join my session and read the transcript.
```

**Value:** Should have

**Effort:** M

---

#### Story #11

As an user, I want to be able to login, so that I can attend conferences.

**Mockup**

![Login Menu](https://i.imgur.com/1vmbEy5.png)

**Acceptance Tests**

```gherkin
Given I want to join/create conferences,
When I fill with valid credentials,
Then I should be redirected to the conference dashboard.
```

```gherkin
Given I want to join/create conferences,
When I fill with invalid credentials,
Then I should be prompted an error.
```

**Value:** Must have
**Effort:** S

### Domain model

![Domain UML](https://i.imgur.com/gNxnD3D.png)

**Description**: All users have one single profile. A user can be a *Speaker* or an *Attendee* depending on the situation.
A conference can be attended by several *Attendees* and can only have **one** *Speaker*.

---

## Architecture and Design

### Logical architecture

To structure our app we used a package diagram:
 * Search package contains the components to create or join a conference and depends on our conference package and an external package (QRCode);
 * Conference package contains the components to get a transcript, choose a language and speak. It also depends on two external packages (SpeechToText and Translation).
 * Account Package contains the components to get a user's conference record and created conferences;
 * Authentication package contains the components to login, register and logout a user;

![Logical Architecture](https://i.imgur.com/Ig0HFMJ.png)

### Physical architecture

For our application, we will be using Flutter, for the framework, and Firebase, for the database. We are also using some API's for our [Speech to Text](https://pub.dev/packages/speech_to_text), [Translation](https://pub.dev/packages/translator)  and [QR Code generation](https://pub.dev/packages/qrscan) functionalities.

![Physical architecture](https://i.imgur.com/CWGckYj.png)

## Test

### Test plan

To test our apllication we implemented Acceptance and Unit tests.
Acceptance Tests are used to verify the expected output through statements that describe all of the actions the user must take to permform a task, and the result of those actions.
Unit Tests are used to verify the expected output after the user interacts with the application.

Unit Tests were with `flutter_test`, while Acceptance Tests were done using `flutter_drive`.

Since our app heavily depends on FireBase, Speech-To-Text and Translation - which are provided by Google - Unit Testing mainly focused on the default and expected widget output.

### Test cases specifications automated

Implemented acceptance tests:
 
- Invalid Login:
  * We simulate a press in the login button, without any information inputed in the apropriate e-mail and password fields;
  * Then, we check if the app displays a message of 'Login failed';
 
- Valid Login:
  * We simulate the input of valid credentials into the apropriate e-mail and password fields;
  * The, we simulate a press in the login button;
  * Finally, we verify if the login was successful by searching for a specific text, located in the dasboard screen;

Implemented Unit Tests:

- Valid Start Screen:
  * We check if the app starts of in our login page, with all inputs empty;
- Valid Dashboard:
  * Pressing on the "Dashboard" button it must go to the dashboard
- Valid Search:
  * Pressing on the "Search" button it must go to the search page
- Valid Create Conference page:
  * Pessing the "Create" button it must go to the "Create Conference" page
  
There are still some cases to be tested and improvements for the future. They are the following:
  * Testing whether the QR code is correctly interpreted
  * Create accounts without populating the database
  * Decouple the need of Firebase(via mocking) to allow the existance of more Unit Tests
---

## Evolution - contributions to open-cx

Describe your contribution to open-cx (iteration 5), linking to the appropriate pull requests, issues, documentation.
