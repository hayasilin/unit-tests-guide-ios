# iOS Unit Tests Guide

[Here is Traditional Chinese version 繁體中文版本](https://github.com/hayasilin/unit-tests-ios-guide/blob/master/README_zh-Hant.md)

This is an iOS unit tests guide that I conclude from my experience. I list some sample code to demonstrate how to write unit test using Swift.

We all know how to write a unit test, However, writing sufficient unit tests in an iOS project that has multiple iOS developers working together is a totally different thing. 

Furthermore, it's a common situation that your team or your team manager asking for higher code coverage for making sure most of the code is protected by unit tests in every code change for good code quality.

Hence, I would like to answer 2 questions with this guide:

- **How to write unit tests in an iOS project that has multiple iOS developers working together?**
- **What is good code coverage to have for iOS development?**

This guide is concluded from my experience, it not necessarily means your team need to follow them all. You can pick up some of useful guides for your team.

In addition, this guide don't include the content of TDD(Test Driven Development).

Finally, I have a repo that simulate a real-life iOS project, which demonstrates how to write unit tests and achieve higher code coverage in a iOS project, you can check [here](https://github.com/hayasilin/unit-tests-ios-demo-project).

## Reference

Here are some of the documents that helps me to create this guide. If something isn't mentioned here, it's probably covered in one of these:

- Dr. Dominik Hauser's [Test-Driven iOS Development with Swift 4](https://www.amazon.com/Test-Driven-iOS-Development-Swift-maintainable/dp/1788475704)

- Raywenderlich's [Unit Testing Tutorial: Mocking Objects](https://www.raywenderlich.com/1752-unit-testing-tutorial-mocking-objects)

- Apple
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
- [3 assertion principles](#3-assertion-principles)
  - [Assert return value](#assert-return-value)
  - [Assert state](#assert-state)
  - [Assert interaction](assert-interaction)
- [Basic test double with Swift](#basic-test-double-with-Swift)
  - [Basic test double class to be tested](#basic-test-double-class-to-be-tested)
  - [Basic test double unit test code](#basic-test-double-unit-test-code)
- [Advanced test double with Swift](#advanced-test-double-with-Swift)
  - [Advanced test double class to be tested](#advanced-test-double-class-to-be-tested)
  - [Advanced test double unit test code](#advanced-test-double-unit-test-code)
- [iOS app development pattern analysis](#ios-app-development-pattern-analysis)
  - [MVC](#mvc)
  - [MVVMC](#mvvmc)
- [What code we do not need to write unit tests](#what-code-we-do-not-need-to-write-unit-tests)
  - [Some codes are not necessarily need to write unit tests](#some-codes-are-not-necessarily-need-to-write-unit-tests)
  - [Public and private functions](#public-and-private-functions)
- [About Code coverage](#about-code-coverage)
- [Code coverage in Xcode](#code-coverage-in-Xcode)
- [How to decide good code coverage](#how-to-decide-good-code-coverage)
- [Conclusion](#conclusion)
- [Appendix](#appendix)
    - [Xcode keyboard shortcut for testing](#xcode-keyboard-shortcut-for-testing)
    - [Unit tests with UI classes](#unit-tests-with-ui-classes)

## Introduction

**This guide firstly demonstrates how to write unit tests in iOS project using Swift.**

This guide will introduce 3 assertion principles to write unit tests.

In addition, this guide shows how to make and use **test double** to make **mock objects** to achieve test isolation for making a solid unit tests that cover most your logic without flaky tests.
Moreover, by using test double, it will help you to test your module's integration with Apple or 3rd party SDK.

**In the second part of this guide, I would like to discuss code coverage in iOS project.**

Code coverage is important because it gives your team information that how many of your code is protected by unit tests in every code change.

I will discuss the formation of Xcode code coverage and its relationship with unit tests and UI tests.

If you want to know more about UI tests in Xcode, you can check my [iOS and Android UI automation tests guide](https://github.com/hayasilin/ios-android-ui-automation-tests-guide).

## 3 assertion principles

### Assert return value

**Function to be tested**

```swift
func configureDataToEven(_ data: [String]?) -> [String]? {
    guard var data = data else { return nil }
        if data.count % 2 != 0 {
            data.removeLast()
        }
    return data
}
```

**Unit test code**

```swift
let sut = YourClass()

func testConfigureDataToEvenIsTwo() {
    let data: [String]? = ["First", "Second", "Third"]
    XCTAssertEqual(2, sut.configureDataToEven(data)?.count)
}

func testConfigureDataToEvenIsNil() {
    let data: [String]? = nil
    XCTAssertEqual(nil, sut.configureDataToEven(data)?.count)
}
```

### Assert state

**Function to be tested**

```swift
var isSuccess: Bool = false

let dataManager = DataManager()

func saveData(_ data: [String]?) {
    let result = dataManager.save(data)
    isSuccess = result
}
```

**Unit test code**

```swift
let sut = YourClass()

let mockDataManager = MockDataManager()

func testSaveDataSuccess() {
    mockDataManager.result = true

    let data = getMockData()

    sut.saveData(data)

    XCTAssertTrue(sut.isSuccess)
}

func testSaveDataFail() {
    mockDataManager.result = false

    let data = getMockData()

    sut.saveData(data)

    XCTAssertFalse(sut.isSuccess)   
}
```

### Assert interaction

**Function to be tested**

```swift
class NetworkService {

    var apiClient = ApiClient()

    func requestAPI(location: CLLocation?, completionHandler: ((Data?, Error?) -> Void)?) {

        let request = createRequest(location)

        apiClient.requestData(urlRequest: request) { (data, response, error) in
            // Data or error handliing
        }
    }
}
```
- Although Above sample code can run and perform unit test, however, it uses ApiClient() to request data and depends the responsee result from server. If server side is under maintenance or under deployment, then the API request might be failed, so does the unit test. This approach also violate **Test Isoloation** principle. The better way is we should use **Test Double** to test the network request here, you can see more detail in the sample code below and [Basic test double with Swift Chapter](#basic-test-double-with-Swift)
- Abbout network request test with server side, it would be categorize in integration tests instead of unit tests. You can see my another aritcle of [API Automation Tests Guide](https://github.com/hayasilin/api-automation-tests-guide)

**Unit test code**

```swift
let sut = NetworkService()

func testRequestAPI() {

    let data = getMockData()

    let mockApiClient = MockApiClient()

    sut.apiClient = mockApiClient

    let dataExpectation = expectation(description: #function)

    sut.requestAPI(location: nil) { (data, error) in

        // ... Verify the interaction between NetworkService and MockApiClient is completed ...
        dataExpectation.fulfill()
    }

    wait(for: [dataExpectation], timeout: 10)
}
```

## Basic test double with Swift

Test double is good to use when you want to isolate unit tests. You can use test double to test functions that handle API request without actual calling the API to ensure test isolation principle.

**There are 3 types of test double:**
- **Stubs:** Theses are used when we need defined return values from a method.
- **Mocks:** They register whether the system under a test calls the expected methods of another instance with expected arguments.
- **Fakes:** They act as stand-ins for real objects that a system under test communicates with. They are needed to make the code compile, but they are not needed to assert that something expected has happened.

For more information about example below, you can check Dr. Dominik Hauser's book: [Test-Driven iOS Development with Swift 4](https://www.amazon.com/Test-Driven-iOS-Development-Swift-maintainable/dp/1788475704).

### Basic test double class to be tested

```swift
protocol SessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension SessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
        return dataTask
    }
}

extension URLSession: SessionProtocol {}

class ApiClient {
    lazy var session: SessionProtocol = URLSession.shared

    func requestData(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let dataTask = session.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
        URLSession.shared.finishTasksAndInvalidate()
    }

    func requestData(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let dataTask = session.dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
        URLSession.shared.finishTasksAndInvalidate()
    }
}
```

### Basic test double unit test code

```swift
class ApiClientTests: XCTestCase {
    
    var sut = MockApiClient()
    var mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)

    override func setUp() {
        sut.session = mockURLSession
    }

    func testRequestWithUrl() {
        let completion = { (data: Data?, response: URLResponse?, error: Error?) in }
        sut.requestData(url: URL(string: "https://unittesting.com")!, completionHandler: completion)
        XCTAssertEqual(mockURLSession.urlComponents?.host, "unittesting.com")
    }

    func testRequestWithUrlRequest() {
        let completion = { (data: Data?, response: URLResponse?, error: Error?) in }
        let urlRequest = URLRequest(url: URL(string: "https://unittesting.com")!)
        sut.requestData(urlRequest: urlRequest, completionHandler: completion)
        XCTAssertEqual(mockURLSession.urlRequest, urlRequest)
    }

    func testWhenJsonIsInvalidReturnError() {
        let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
        let jsonData = "{\"token\": \"1234567890\"}".data(using: .utf8)

        sut.session = MockURLSession(data: jsonData, urlResponse: nil, error: error)

        let errorExpectation = expectation(description: #function)
        var catchedJsonDictionary: [String: Any]? = nil
        var catchedError: Error? = nil

        let urlRequest = URLRequest(url: URL(string: "https://unittesting.com")!)
        sut.requestData(urlRequest: urlRequest) { (data, response, error) in
            guard let data = data else {
                return
            }
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonResponse as? [String: Any] else {
                return
            }

            catchedJsonDictionary = jsonDictionary
            catchedError = error
            errorExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(catchedJsonDictionary)
            XCTAssertNotNil(catchedError)
        }

    }
}

class MockApiClient: ApiClient {
    override func requestData(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlRequest = URLRequest(url: URL(string:"https://unittesting.com")!)
        let dataTask = session.dataTask(with: urlRequest, completionHandler: completionHandler)
        dataTask.resume()
    }
}

class MockURLSession: SessionProtocol {
    var url: URL?
    var urlRequest: URLRequest?
    private let dataTask: MockTask

    var urlComponents: URLComponents? {
        guard let url = url else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        dataTask = MockTask(data: data,
                            urlResponse: urlResponse,
                            error: error)
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.urlRequest = request
        dataTask.completionHandler = completionHandler
        return dataTask
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.url = url
        dataTask.completionHandler = completionHandler
        return dataTask
    }
}

class MockTask: URLSessionDataTask {
    private let data: Data?
    private let urlResponse: URLResponse?
    private let responseError: Error?
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var completionHandler: CompletionHandler?
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data

        self.urlResponse = urlResponse
        self.responseError = error
    }
    override func resume() {
        DispatchQueue.main.async() {
            self.completionHandler?(self.data, self.urlResponse, self.responseError)
        }
    }
}
```

## Advanced test double with Swift

Usually it's hard to test your code's interaction with Apple or 3rd party SDK because you can't control what data they give you. However, by using test double you can do that and test your class's interaction with Apple's iOS SDK in a more controlled situation.

Below example demonstrtes how to test your functions if their result depends on Apple's Core Location Framework.

For more information you can also check 2018 WWDC session [Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/).

### Advanced test double class to be tested

```swift
protocol LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    func requestLocation()
}

protocol LocationFetcherDelegate: class {
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation])
}

extension CLLocationManager: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegate? }
        set { delegate = newValue as! CLLocationManagerDelegate? }
    }
}

class LocationManager: NSObject {

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        return locationManager
    }()

    var currentLocationCheckCallback: ((CLLocation) -> Void)?

    private var locationFetcher: LocationFetcher

    init(locationFetcher: LocationFetcher = CLLocationManager()) {
        self.locationFetcher = locationFetcher
        super.init()
        self.locationFetcher.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationFetcher.locationFetcherDelegate = self
    }

    func requestLocation(completion: @escaping (Bool, CLLocation) -> Void) {
        self.currentLocationCheckCallback = { [unowned self] location in
            completion(self.isPointOfInterest(location), location)
        }
        locationFetcher.requestLocation()
        requestLocation()
    }

    func isPointOfInterest(_ location: CLLocation) -> Bool {
        return true
    }

    private func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: LocationFetcherDelegate {

    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.currentLocationCheckCallback?(location)
        self.currentLocationCheckCallback = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationFetcher(manager, didUpdateLocations: locations)
        locationManager.delegate = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
}
```

### Advanced test double unit test code

```swift
class LocationManagerTests: XCTestCase {
    struct MockLocationFetcher: LocationFetcher {
        weak var locationFetcherDelegate: LocationFetcherDelegate?

        var desiredAccuracy: CLLocationAccuracy = 0

        var handleRequestLocation: (() -> CLLocation)?
        func requestLocation() {
            guard let location = handleRequestLocation?() else { return }
            locationFetcherDelegate?.locationFetcher(self, didUpdateLocations: [location])
        }
    }

    func testLocationManager() {
        var locationFetcher = MockLocationFetcher()
        let requestLocationExpectation = expectation(description: "request location")
        locationFetcher.handleRequestLocation = {
            requestLocationExpectation.fulfill()
            return CLLocation(latitude: 37.3293, longitude: -121.8893)
        }

        let sut = LocationManager(locationFetcher: locationFetcher)
        let completionExpectation = expectation(description: #function)
        sut.requestLocation { (isPointOfInterest, location) in
            XCTAssertTrue(isPointOfInterest)
            XCTAssertNotNil(location)
            completionExpectation.fulfill()
        }

        wait(for: [requestLocationExpectation, completionExpectation], timeout: 10)
    }
}
```

## iOS app development pattern analysis

After we know how to write unit tests in Xcode, next step we need to analysis which part of iOS project should we write unit tests.

### MVC

In the era of app development, both server side and client side are play important roles.
Client side or the app, requests data from server side through API, and ideally most of people use MVC to architect their app.
We know for the logic or business rules we need to write unit tests to cover, so we write unit tests for classes like API client, models, or controllers' classes.

For the view classes, under the MVC pattern, it shouldn't have logic, so instead of writing unit tests, we need to write UI tests to cover them and I will explain more in latter chapter.

However, In the iOS development world, the iOS MVC is a little different from the traditional MVC we know.

As most of you know, iOS use UIViewController to do the both tasks of controller and view, it’s pretty straightforward in small app project but it will become a big problem in large app project.
Because in large app project, you will end up to have a mass UIViewController which has thousands of code lines, it's painful to maintain or change the code and even worse, the code for logic and business rules are mixed together with view's code and it’s hard to separate them and even harder to write unit tests for those logic or business rule's code.

To solve this issue, recent year iOS world starts to use new design patter like MVVMC or VIPER. 

Below I will take MVVMC as example,

### MVVMC

MVVMC stands for a pattern that is consist of Model, View, ViewModel, and Coordinator.

By using MVVMC, we use a class called ViewModel which is responsible for the logic and business rules and it use data binding to communicate with the UIViewController.

Now UIViewController is belong to UI category and it shouldn’t have any logic code.
By separating logic and UI clearly, we know we should write unit tests for ViewModel classes, and write UI tests to cover our UIViewController classes

Then the formula to know where should we write unit tests is going to be more clearer, we should write unit tests for classes like API client, mangers, helpers, database related classes, and models.

For the classes like UIView, UITableViewCell, UICollectionViewCell, or the class that handle UI animation, we should write UI tests to cover them.

There is one more thing in MVVMC, which is the Coordinator. Coordinator is responsible for handling UI's transition. Although it sounds like Coordinator belongs to UI category, however, it may have some logic in Coordinator classes. You can write unit tests for the logic part and write UI tests for the UI part.

This concept of writing unit tests for logic and business rules, and writing UI tests for UI classes not only can be applied to iOS, it can also be applied to Android development too.

Of course, in reality there is will always an exception. If you have no choice but need to include logic code in UI related classes due to some reasons, you can still write unit tests for the UI class if you can separate the logic code with other code clearly. 

## What code we do not need to write unit tests

### Some codes are not necessarily need to write unit tests

Although we want to cover as many code as we can, however, there are some codes that is hard to cover or you don't need to spend your time to cover because it might not be necessarily in reality.

- iOS System callback that has no clear logic to verify.
- UI and view classes, which should only be responsible for UI display.
- **More...**(In reality things will not alwasy be perfect, so does the code)

### Public and private functions

You should only need to test your pulbic functions in a class.

In theory, once you test all public functions in a class, all private functions in that class should be covered as well, because private functions are used by public functions.

If private function's code is not covered, maybe you need to check and try refactor the code to make private functions are covered once all public functions are tests.

## About code coverage

We all know what is code coverage, but when thing comes to a large iOS app project having multiple iOS developers working on it, the concept of code coverage starts to become complex. Then your team or your team manager ask for higher code coverage in order to have a good code quality during every code change. Then the question is what is the code coverage number need to be targeted for an iOS project? Like 100% code coverage? But is that possible and what obstacle will the team have? There is no text book give us an answer for that, especially in iOS development world, so we need to define for ourselves.

When it comes to code coverage, one question is often asked in my team, which is **should we write unit tests for UI classes**?

App is not application that only has pure logic to verify like server side, apps needs to show UI, which needs many codes to construct it. In fact, majority code line in app is UI related code. Hence, if you don't have code coverage on those UI classes, your code coverage won't be high.

In reality, there are many ways that we don't need to care about UI classes and still can have high code coverage.
For example, the most common way is we only calculated the classes that contain logic or business rules, and we exclude UI classes.

However, is that a real answer to solve our question and guarantee most of our code is protected in every code change?
What is worse, to certain extreme code coverage will end up to be a simple number's game. You can get high code coverage by only calculates classes that has unit tests and ignore those classes which don't have unit tests, even some of which have important logic.

Unit tests and code coverage can't 100% guarantee our app will be flawless, but it helps to provide developers with a quick feedback that we didn't break things while changing code.

In order to get the best practice of developing unit tests and have good code coverage in iOS project, I would like to dig in and study how Xcode helps us to write unit tests and generate code coverage report.

## Code coverage in Xcode

When we run unit tests in Xcode, we will see code coverage on those classes which has logic or business rules if we write unit tests.

Obviously our UI classes won’t have any code coverage because they don't have any logic code so we don’t write unit tests for them.

However, if we have written UI tests for those UI classes, after we run UI tests in Xcode, we will see code coverage on those UI classes in Xcode as well. Because UI tests will run the UI related code so it will be counted.

So it’s making sense that code coverage concept can also apply to UI classes by using UI tests.

As a result, in Xcode the concept between unit tests and UI tests is we need to write unit tests for logic classes, and writing UI tests for UI classes to create an overall code coverage report.

If you want to know more about UI tests in Xcode, you can check my [iOS and Android UI automation tests guide](https://github.com/hayasilin/ios-android-ui-automation-tests-guide).

<img src="https://github.com/hayasilin/unit-tests-ios-guide/blob/master/resources/xcode_code_coverage.png">

## How to decide good code coverage

We know unit tests are essential to have higher code coverage, but now we also know app has large portion of UI code base and for that we need to write UI tests.

However, as [testing pyramid](https://github.com/hayasilin/ios-android-ui-automation-tests-guide#follow-testing-pyramid) told us, we won’t write UI tests on every cases, our UI tests only need to cover the happy path.
So some part of UI classes may not be able to cover, for example like error display page.

In addition, in large app project, there will be some code that may not be easy to write unit tests or your team needs extra effort to cover them.

For example, maybe your app uses some iOS system callback functions but there is no obvious logic to verify, or there is some legacy code that need to be refactored first before adding any unit tests.
In reality, things are not always to be perfect.

My experience is by following this guide, a 5 members iOS team can keep code coverage around 60% in an agile development environment.

I think trying to keep code coverage up to 70% in every code change is doable, but firstly you need to make sure all of your team members are following this guide and not only they are writing unit tests, they also need to write UI tests as well.

I don't have experience of keeping code coverage up to 80% in a large iOS project, but I assume it needs to spend many resources and times to make sure every code line is well covered in order to achieve the number, even some codes  might not be necessary to cover them

In reality, most of development team are pushing by business plan and new features and they don't have extra resources to make sure every code line is covered, so your team need to think twice before setting a code coverage target. Make sure you use the reasonable resource to achieve the right code coverage for your team.

In conclusion, in iOS project, if your team members are not familiar with unit tests, test double, or UI tests, you can target 40% ~ 50% code coverage first.

If your team is familiar with unit tests and UI tests, by following this guide, you can set a code coverage target around **60% ~ 70%** in every code change, that is good code coverage to have for a team. Because that give us enough confidence that most of our code is protected by unit tests in every code change, and we don't need to use too much resource to only pursuing higher number.

We should use most of our resource on other important tasks, such as new feature development.

## Conclusion

- Use 3 assertion principles to write unit tests.
- Use test double to isolate the object you want to test.
- Use MVVMC (or VIPER) instead of using MVC in medium and larget iOS project.
- Test public functions only. If private function's code is not covered, maybe you need to think to refactor the code.
- Some codes might not need to write unit tests, just leave it.
- Write unit tests for logic and business rules classes first, then write UI tests to cover UI classes.
- Make sure you use the reasonable resource to achieve the right code coverage for your team.

## Appendix

### Xcode keyboard shortcut for testing
- Run the test: ⌘ U
- Run only one test: ctrl ⌥ ⌘ U
- Re-run the previous set of tests: - ctrl ⌥ ⌘ G

### Unit tests with UI classes

According to Dr. Dominik Hauser's [Test-Driven iOS Development with Swift 4](https://www.amazon.com/Test-Driven-iOS-Development-Swift-maintainable/dp/1788475704), we can still wrtie unit tests to UI classes. 

Although personally I don't fully agree that we need to write unit tests for UI classes, however, in reality if your iOS project's UI classes still have logic or business rule's code, or your can't have UI tests in your team's iOS project for some reasons, you can check how Dr. Dominik Hauser's book to test UI classes like UIViewController.

Below code is just for your reference.

**Class to be tested**

```swift
class ItemListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let itemManager = ItemManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let itemCellNib = UINib(nibName: String(describing: ItemCell.self), bundle: nil)
        tableView.register(itemCellNib, forCellReuseIdentifier: String(describing: ItemCell.self))

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        self.navigationItem.rightBarButtonItem = addBarButtonItem

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showDetailVC(sender:)),
            name: NSNotification.Name("ItemSelectedNotification"),
            object: nil
        )
    }

    @objc func addItem(sender: UIBarButtonItem) {
        let inputVC = InputViewController()
        inputVC.itemManager = itemManager
        present(inputVC, animated: true, completion: nil)
    }

    @objc func showDetailVC(sender: NSNotification) {
        guard let index = sender.userInfo?["index"] as? Int else { fatalError() }

        let detailVC = DetailViewController()
        detailVC.itemInfo = (itemManager, index)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

**Unit test code**

```swift
class ItemListViewControllerTest: XCTestCase {

    var sut = ItemListViewController()

    override func setUp() {
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
    }

    func testTableViewAfterViewDidLoadIsNotNil() {
        XCTAssertNotNil(sut.tableView)
    }

    func testLoadingViewSetsTableViewDataSource() {
        XCTAssertTrue(sut.itemManager is ItemManager)
    }

    func testAddBarButtonItemWithSelfAsTarget() {
        let target = sut.navigationItem.rightBarButtonItem?.target
        XCTAssertEqual(target as? UIViewController, sut)
    }

    func testAddItemPresentsInputViewController() {
        XCTAssertNil(sut.presentedViewController)
        UIApplication.shared.keyWindow?.rootViewController = sut

        guard let addBarButtonItem = sut.navigationItem.rightBarButtonItem else {
            XCTFail() 
            return 
        }

        guard let action = addBarButtonItem.action else { 
            XCTFail() 
            return 
        }

        sut.performSelector(onMainThread: action,
                            with: addButton,
                            waitUntilDone: true)

        XCTAssertNotNil(sut.presentedViewController)
        XCTAssertTrue(sut.presentedViewController is InputViewController)

        guard let inputViewController = sut.presentedViewController as? InputViewController else {
            XCTFail()
            return
        }

        XCTAssertNotNil(inputViewController.titleTextField)
    }

    func testShareItemManagerWithInputViewController() {
        guard let addBarButtonItem = sut.navigationItem.rightBarButtonItem else { 
            XCTFail()
            return 
        }

        guard let action = addBarButtonItem.action else { 
            XCTFail() 
            return 
        }

        UIApplication.shared.keyWindow?.rootViewController = sut

        sut.performSelector(onMainThread: action,
                            with: addButton,
                            waitUntilDone: true)

        guard let inputViewController = sut.presentedViewController as? InputViewController else { 
            XCTFail() 
            return
        }

        guard let inputItemManager = inputViewController.itemManager else { 
            XCTFail() 
            return
        }

        XCTAssertTrue(sut.itemManager === inputItemManager)
    }

    func testNotificationPushesDetailViewController() {
        let mockNavigationController = MockNavigationController(rootViewController: sut)
        UIApplication.shared.keyWindow?.rootViewController = mockNavigationController
        
        sut.itemManager.add(ToDoItem(title: "foo"))
        sut.itemManager.add(ToDoItem(title: "bar"))
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ItemSelectedNotification"),
            object: self,
            userInfo: ["index": 1])
        
        guard let detailViewController = mockNavigationController.lastPushedViewController as? DetailViewController else {
            XCTFail()
            return
        }

        guard let detailItemManager = detailViewController.itemInfo?.0 else { 
            XCTFail()
            return
        }

        guard let index = detailViewController.itemInfo?.1 elseelse { 
            XCTFail()
            return
        }

        detailViewController.loadViewIfNeeded()

        XCTAssertNotNil(detailViewController.titleLabel)
        XCTAssertTrue(detailItemManager === sut.itemManager)
        XCTAssertEqual(index, 1)
    }
}

class MockNavigationController : UINavigationController {
    var lastPushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        lastPushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}
```
