---
layout: post
title:  "PyCon 2018. First Day"
date:   2018-05-11 17:12:00 -0600
categories: article
excerpt: PyCon 2018, first 2018
tags: 
  - Python
  - PyCon
  - Community
seo:
  type: Article
published: false
---
#### Welcoming

- Live captioning
- Small hiccup with the slides which was turned into a light weight joke. "That's not my style"
- PyCon code of conduct. Make people aware and how to enforce it.
- Quite and mothers rooms.
- Try to meet at least as many attendees as PyCon's you've attended.
- Explaining the format of PyCon and what has happened:
    - Tutorials
    - Education Summit **This is really important, what's up?**
    - SPonsor Workshop
    - Newcomer Orientation
    - Opening Reception
- PyCon Charlas
- PyCon Hatchery
- Poster Session
- Open Spaces @openspacesbot #PyConOpenSpaces
- Lightning Talks. Solomon Hikes presented docker in a lightning talk.
- "Hallway Track". There are things happening on the hallway.
- Expo Hall, Thur - Sat.
    - Startup Row, competed for this
- Job Fair on Sunday
- Breakfast and run/walk
- Evenings Dinners
- Things for kids and things for moms
- Development Strips. Next Monday - Thur to help open source.
- Cleveland Ohio welcome

#### Keynote (Dan Callahan - PyPI) @callahad

Started to talk about IBM's beginning (I'm going to talk about platforms).
IBM was a bad computer. Dan's father decided to buy a computer because of IBM and he started on an IBM.
Dan strated with basic and he didn't realized but the languages he was going to use were being chosen by him.
The platform he was using will influence what programming languages he was going to use.
He strated with some linux and php but felt inadequate. He remembers TI-82 and how he used to do stuff with basic on it.
What would computers look like for his child's generation.

Mozilla uses a lot of python. Python is a tool. This year he realized he moved to platforms where python don't have great stories.
"Python is the 2nd best language for everything". This is good because python is versatile.
"Why are we programming if not to serve people and solve human problems?"
Python isn't the 2nd best choice. Looks around (linux, etc...) python is an amazing tool. But there's also Androind, IOS, etc...
This is the platform that is at hand. 1/3 of children own their own tablet.
Those children will use tools that are ok on those devices.
The Web is a consolidating platform. Fridges with OSs with browsers on it.
Nobody know what is going to happen in the future but any future platform will have access to the web.
No central controll, it is comptetitive and W3c helps on getting the web everywhere.
Javascript is popular because it is nataive to the web.

Maybe we can put python on the web. For instance, we already have python notebooks. Notebooks are in your browser because the browser is a good platform.
Python is good at things that JS is not. There are still good things build with JS despite it's "flaws".
The problem with python is that it has to run somewhere. If we could bring python to the web then we can bring python everywhere.

The solution is Webassembly, is a complement of javascript.
Low level languages pros are portability and performance like numpy uses C.
Most programming lanaguages makes it easy to talk between high level and low level.
So, what is this in the web?
You can write somethin in web assembly and compile it then use it in python or you can run it in your browser.
AutoCAD and compiled it directly in a browser using WebAssembly. Shown on Google I/O

"The birth & Death of Javascript". That talk was old using Windows 3
He fired up windows 3! (a video of an emulator) and then netscape. IT still feels like the web and that is running on FireFox.
We can start looking at the web like a computer. Can we just compile python on the web and that's it?
No, python needs a CPU.
PyPi.js is pypi compiled into the web!
sometimes you don't want all of python, maybe you just want list comprehensions.

How do we bring python to the web? We don't know but we have some tools to start!

#### Code Reviews Using Art Crtique Priniciples (Stacy Morse @geekgirlberta codecrit.com)

The main point is to make fellow developers happy.
The rules (no rules, chaos. Chaos is the enemy of productivity):
    - Respect
    - Be Prepared
    - Stay netural where being neutral is required
    - Constructive criticism only
    - Stay on point and focused
    - Mandatory participation

Pre Code REview:
    - Identify your work
    - Run All relevant testing
    - Know your code
    - Check code meets all requirements
    - Do not waste other people's time

Code Critique Stages:
    - Description
        - identify
        - Inventory
        - Referal
    - Analysis
        - New Code + Old Code
        - Facts needed for critical interpretation
    - Interpreteation
        - Description + Analysis
    - Judgment
        - Can the code ship

Inventory:
    - Do not just hand out checkboxes. You have to read the code. It varies from company to company.
    - What do you do with inventory? If there's any issues with it then send them back with a reason.
    - Use the inventory as a chance to connect with your co-workers.

Constructive criticism:
    - Are not compliments.
    - some times you're going to hear things that you don't like. It happens. Deal with it.
    - Be clear
    - Provide solutions to fix the problem.
    - Use the notes from your inventory.
    - Contribute to a better environment.
    - No malice!

One mark of an educated person is the abliity to recognize and evaluate excellence independently. This ablility, however, does not come from memorizing lists of so-called masterpieces.


Code reviews are not mentorship. CR are about being productive.
Just a :+1: is not a code review.

#### Code like an accountant: Designing data systems for accuracy, resilience and auditability. (Sophie Rapoport)

Custom trust is important. Read "Site relaiability engineering".
Customres asks, can I trust you with my data?
How reliable is the data that we give them?
from accounting, the principale of double book keeping.
We need a complete and immutable record of transaction history that can be externally enforced. (keep records)
the second principle is the principle of double entry. the notion that every eentry to an account requires a coresponding and opposite entry to a different account. Every transsaction can be described by equial and opposite movements of money.
She designes financial systems.
- strategies for monitoring data
    - "The rules that catch real incidents most often should be as simple, predictable and relabie as possible"
    - Assets = revenue + liabilities (double book keeping)
    - Tickets example, check money in and money out.
    - Check the correctness of ht emost cirital elements of your data using out of band adata validators, even if api semantics suggest that you need to do so"
    - Item-level Reconciliation.
    - "100% is probably never the right reliability target: not only is it impossible to achieve it is more than users want or noticed.
    - Build tools to make data management easy.
- processes for handling data
- how to think like an auditor
    - Auditors are pain in the butt
    - Append-only datastore
    - Automatic abackups
    - Single source of tuth for financial data
    - Work with accounting to structure the source of trutha
    - Data flow, what is the financial ilfecycle - both in product and in finance?

#### Beyond Unit Tests: Taking your Testing to the Next Level

- Write your unit tests.
- Writing unit tests by hand can still be flawd.
    - There are edge cases which you can't realize
- Property-Based testing or "Invariant" Testing
    - Hypothesis library
    - What is a good property?

- Types will not save us. We can't do any behaviour with types.
- Design By Contracts
    - Using assertions to make sure things are running correct.
    - You can create a full specification with contracts
    - Contracts + Property based are integration tests

- Stateful testing from hypothesis
- Formal methods

#### Software Library APIs: Lessons Learned from scikit-learn (Liz Sander)

- Make your api clear and consistent
- find an abstraction that mirrors your mental model
- Think about developers as users

#### Flourishing FLOSS: Making your project successful (Anna Osswoski)

- Good documentation
    - Encourage documentation first.
    - People will think about the change submission first and how it works.
- Open soruce projects need contributions from people of all experiences.$
- Helping someone succeed is the best feeling in the world!
- Code of conduct
- listen to your contributors
- offer financial support
- esatblish good communication
- thorough docs
- aknowlege all contribs
- offer mentorship
- find contributors
- work on a website
- recognize the importance of contribs
- give ownership
- learn to say no and document
- nurture your community

#### Beyond Scrapping: How to use machine learning when you're not sure where to start ( Julie Lavoie )

- Extracting the date of any page online
- Mechanical Turk, you program humans
- soft devs make mistakes
- use machine learning. Supervised learninga
- Machine learning is a lot of work
    - Only use it if the volume of your data, or problem cocmplexity is too much for pevious solutions
- Get clues. Linguistics, rendering/presentation and markup cues.
- How do I setup the problem in a way that machine learning can answer it.
1. Training a model
2. Get all dom elements w dates
- Machine learning is about thinking statistically 

#### Taking Django Async (Andrew Godwin)

    Webserver <->                 <-> Django
                   Channel Layer
    Webserver <->                 <-> Django

Better to wrap django n an AsyncIO native web server
- sync_to_async:
    - Synchronous code has to run in threads. ThreadPoolExecutor does most of the hard work
    - Caling the orm
    - rendering etmplates
    - handing off to django views
- async_to_sync:
    - Async code runs on the event loop. We need to go find it! Or make our own.
    - Make a future
    - jump to the main thread and add the corutine
    - tie the coroutine's end to triggering the future
    - block the thread on the future

#### Reactive Programming with RxPy

Error handling in reactive is done by using en event.
There are observers and you can subscribe to them. Nothing happens until somebody access the data.


#### Keynote #2 (Ying Li)

More developers knowing about security is better for the whole eco-system
You don't have to be an expert in security to do some basic stuff.
Like having a baby, you don't need medical training to have a baby. You create a list of needs and do your best.
Security for babies, CI for babies.
27% of the python community are web devs.
Framework and libraries help with security. The developer still needs to know about these features to NOT bypass them.
OWASP is a great resource.
27% (jetbrains poll) are data scientists.
There are security concerns in data, too. Avoid exposing it, etc..
9% of pyton users focus on dev ops admin and automation.
Educator should bring up security often and early.
Where is the endpoint accepted, where is date stored, how does data travels, what type of access do you need?
Attackers don't usually use advanced attacks. They stick to true and tested attacks.
It's easier to protect from these types of attacks.
The back to sleep campaign for babies. SIDS dropped by over 50%
lowering CSRF attacks. Check OWASP survey.

#### Keynote #3 (Qumisha Goss)

Tynker.com, how did it start?
Kids wanted to do more, not just "baby stuff"
Python for kids.

#### Intuitive data visualization in augmented reality

Human beings have challenges for physical en mental environments.
But we are innumerate. Innumeracy: challenges to conceputalize large numbers.
- Loossing context
- De-humanization
We become factories of creating numbers. Data.
The challenge is to interpret all theese numbers.
augmented reality as a corective tool for innumeracy.
Step 1: Use Blender to load data
Step 2: Making Bar Charts
Step 3: Blender to Unity
Step 4: Animations in Unity

#### How netflix does failovers in 7 minutes flat (Amjith Rmanujam)

Fiailover: Standby ystem takes over when the main system fails.
Netflix does not own data centers. They use AWS.
Netflix went down and it was because ELB was down.
Regional failovers
Prerequisites:
    - Stateless services: if I move a service from one machine to another machine nothing should change. Chaos Monkey
    - Regional replication of data.
Failover Candidate:
    - Infrastructure problem isolated to one region
    - Problem won't follow if we move traffic
    - Bad code deploy in a region
Detect the problem:
    - SPS stream starts per seconda.
    - Scaling the saviours.
    - **Netflix Atlas**
Scale the savior regions
Shift traffic

Failovers should be transparent to service owners.

Actions:
    - Periodic tasks
        - Fetch historical data
        - Predict cluster sizes
        - Manage dark clusters
    - Triggered tasks
        - Ungate dark instances
        - Transplant instances
        - Traffic shift

#### Keynote
