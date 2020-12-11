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

Conferences are great way of sharing knowledge, sadly not everyone can enjoy them equally. Hearing problems and the language barrier are a major turndown for lots of users. InstantWords, using Speech-To-Text technology, provides transcripts, directly to your phone, in a wide array of languages enabling a brand new audience to enjoy them.



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




This section will contain the requirements of the product described as **user stories**, organized in a global **[user story map](https://plan.io/blog/user-story-mapping/)** with **user roles** or **themes**.

For each theme, or role, you may add a small description. User stories should be detailed in the tool you decided to use for project management (e.g. trello or github projects).

A user story is a description of desired functionality told from the perspective of the user or customer. A starting template for the description of a user story is 

*As a < user role >, I want < goal > so that < reason >.*

**INVEST in good user stories**. 
You may add more details after, but the shorter and complete, the better. In order to decide if the user story is good, please follow the [INVEST guidelines](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/).

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
For each user story you should write also the acceptance tests (textually in Gherkin), i.e., a description of scenarios (situations) that will help to confirm that the system satisfies the requirements addressed by the user story.

**Value and effort**.


At the end, it is good to add a rough indication of the value of the user story to the customers (e.g. [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method) and the team should add an estimation of the effort to implement it, for example, using t-shirt sizes (XS, S, M, L, XL).

### Domain model

![Domain UML](https://i.imgur.com/gNxnD3D.png)

**Description**: All users have one single profile. A user can be a *Speaker* or an *Attendee* depending on the situation.
A conference can be attended by several *Attendees* and can only have **one** *Speaker*.

---

## Architecture and Design
The architecture of a software system encompasses the set of key decisions about its overall organization. 

A well written architecture document is brief but reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the overall components of the project and their interrelations. You should also describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.

### Logical architecture
The purpose of this subsection is to document the high-level logical structure of the code, using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system both in a horizontal or vertical decomposition:
* horizontal decomposition may define layers and implementation concepts, such as the user interface, business logic and concepts; 
* vertical decomposition can define a hierarchy of subsystems that cover all layers of implementation.

**Text to be added**

![Logical Architecture](https://i.imgur.com/JtcFxJU.png)

### Physical architecture
The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams or component diagrams (separate or integrated), showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for openCX are, for example, frameworks for mobile applications (Flutter vs ReactNative vs ...), languages to program with microbit, and communication with things (beacons, sensors, etc.).

For our application, we will be using Flutter, for the framework, and Firebase, for the database. We are also using some API's for our [Speech to Text](https://pub.dev/packages/speech_to_text), [Translation](https://pub.dev/packages/translator)  and [QR Code generation](https://pub.dev/packages/qrscan) functionalities.

![Physical architecture](https://i.imgur.com/CWGckYj.png)



### Prototype
To help on validating all the architectural, design and technological decisions made, we usually implement a vertical prototype, a thin vertical slice of the system.

In this subsection please describe in more detail which, and how, user(s) story(ies) were implemented.

---

## Implementation
Regular product increments are a good practice of product management. 

While not necessary, sometimes it might be useful to explain a few aspects of the code that have the greatest potential to confuse software engineers about how it works. Since the code should speak by itself, try to keep this section as short and simple as possible.

Use cross-links to the code repository and only embed real fragments of code when strictly needed, since they tend to become outdated very soon.

---
## Test

There are several ways of documenting testing activities, and quality assurance in general, being the most common: a strategy, a plan, test case specifications, and test checklists.

In this section it is only expected to include the following:
* test plan describing the list of features to be tested and the testing methods and tools;
* test case specifications to verify the functionalities, using unit tests and acceptance tests.
 
A good practice is to simplify this, avoiding repetitions, and automating the testing actions as much as possible.

---
## Configuration and change management

Configuration and change management are key activities to control change to, and maintain the integrity of, a project’s artifacts (code, models, documents).

For the purpose of ESOF, we will use a very simple approach, just to manage feature requests, bug fixes, and improvements, using GitHub issues and following the [GitHub flow](https://guides.github.com/introduction/flow/).


---

## Project management

Software project management is an art and science of planning and leading software projects, in which software projects are planned, implemented, monitored and controlled.

In the context of ESOF, we expect that each team adopts a project management tool capable of registering tasks, assign tasks to people, add estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Example of tools to do this are:
  * [Trello.com](https://trello.com)
  * [Github Projects](https://github.com/features/project-management/com)
  * [Pivotal Tracker](https://www.pivotaltracker.com)
  * [Jira](https://www.atlassian.com/software/jira)

We recommend to use the simplest tool that can possibly work for the team.


---

## Evolution - contributions to open-cx

Describe your contribution to open-cx (iteration 5), linking to the appropriate pull requests, issues, documentation.
