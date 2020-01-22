# iOS Unit Tests Guide

This is an iOS unit tests guide that I conclude from my experience. I list some sample code to demonstrate how to write unit test in iOS. Furthormore, I will give a real life iOS project to show how to achieve higher code coverage.

I would like to answer a question that many iOS team keep searching for answer:

**What is good code coverage to have for iOS app development and how to achieve it?**

## Reference

Here are some of the documents. If something isn't mentioned here, it's probably covered in one of these:
- iOS
  - [About Testing with Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/01-introduction.html)
  - [Using Unit Tests](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTesting.html)
  - [Testing Your Xcode Project](https://developer.apple.com/documentation/xcode/testing_your_xcode_project)
  - [XCTest](https://developer.apple.com/documentation/xctest)
  - **WWDC**
    - 2019
      - [Testing in Xcode](https://developer.apple.com/videos/play/wwdc2019/413/)
    - 2018
      - [What's New in Testing](https://developer.apple.com/videos/play/wwdc2018/403)
      - [Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/)
    - 2016
      - [Advanced Testing and Continuous Integration](https://developer.apple.com/videos/play/wwdc2016/409)
    - 2015
      - [Continuous Integration and Code Coverage in Xcode](https://developer.apple.com/videos/play/wwdc2015/410/)

## Table of Contents
- [Introduction](#introduction)
- [Unit testing in Xcode](#unit-testing-in-xcode)
- [iOS app development pattern analysis](#ios-app-development-pattern-analysis)
- [How to decide good code coverage](#how-to-decide-good-code-coverage)
- [What classes and functions should we cover](#what-classes-and-functions-should-we-cover)

## Introduction

We all know how to write a unit test, but when thing comes to a large iOS app project having multiple iOS developers working on it, things start to become complex. Then your team or your team manager ask for higher code coverage in order to have a good code quality during every code change. Then the question is what is the number for good code coverage in iOS development? Like 100% code coverage? But it’s that possible and what obstacle will our team have? There is no text book give us an answer for that, especially in iOS development world, so we need to define for ourself.

When it comes to code coverage, one question is often asked in my team, which is **should we write unit tests for UI classes**?

App is not application only has pure logic to verify like server side, apps needs to show UI, which needs many codes to construct it.

There are many ways that we can have code coverage to make the team don’t need to care about UI cleasses.
For example, the most common way is we only calculated the classes that contain logic or business rules, and we exclude UI classes.
However, is that a real answer to solve our question?
Let’s think it from the default perspective for app development.

## Unit testing in Xcode

When we run unit tests in Xcode, we will see code coverage on those classes which has logic or business rules if we write unit tests.
Obviously our UI classes won’t have any code coverage because we don’t write unit tests for them.
However, if we have written UI tests for those UI classes, after we run UI tests in Xcode, we will see code coverage on those UI classes in Xcode as well.
So it’s making sense that code coverage concept can also apply to UI classes by using UI tests.
As a result in Xcode, the concept between unit tests and UI tests is we need to write unit tests for logic classes, and writing UI tests for UI classes.

## iOS app development pattern analysis

**MVVMC**

Let’s break down our application further, In the era of app development, both server side and client side are play important roles.
Client side or the app, requests data from server side through API, and ideally use MVC to architect our app.
We know for the logic or business rules we need to write unit tests to cover, so we write unit tests for API client, model, or controllers classes.
For the View classes it has no logic, so instead of writing unit tests, we need to write UI tests to cover them.

However, In the world of iOS development, the iOS MVC is a little different from the traditional MVC we know.
As most of you know, iOS use UIViewController to do the both tasks of controller and view, it’s pretty straightforward in small app project but it will become a big problem in large app project.
Because in large app project you will end up to have a mass UIViewController which has thousands of code lines, it's painful to maintain or change the code and even worse, the code for logic and business rules are mixed together with views and it’s hard to separate them and even harder to write unit tests for logic or business rules.

To solve this issue, recent year iOS world start to use new design patter like MVVM or VIPER. 
Let me take MVVM as example,
By using MVVM, we use a class called ViewModel which response for the logic and business rules.
It use binding to communicate with the UIViewController.
Now UIViewController is belong to UI tests category and it shouldn’t have any logic code.
By separate logic and UI clearly, we know we should write unit tests for ViewModel classes, and write UI tests to cover our UIViewController classes

Then the formula to have good code coverage is going to be more clear, we should write unit tests for classes like API client, manger, helper, DB related classes, and models.
For the classes like View, Cell, or the class that handle UI animation, we should write UI tests to cover them.
This concept of writing unit tests for logic and business rules and writing UI tests for UI classes not only can be apply to IOS, we can also apply to Android app.
Our Android TODAY app also combines unit tests and UI tests to form code coverage by using default cradle wrapper command line tool.

**VIPER**

## How to decide good code coverage

We know unit tests are essential to have higher code coverage, but now we also know app has large portion of UI code base and for that we need to write UI tests.

However, as testing pyramid told us, we won’t write UI tests on every cases, our UI tests only need to cover the happy path.
So some part of UI classes may not be able to cover, for example like error display page.

In addition, in large app project, there will be some code that may not be easy to write unit tests or your team needs extra effort to cover them.
Such as maybe your app uses some iOS system callback functions but there is no obvious logic to verify.
Or there are some legacy code that need to be refactored first before adding any unit tests.
In reality, things are not always to be perfect.

## What classes and functions should we cover