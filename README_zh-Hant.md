# iOS 單元測試規範

[Here is English version](https://github.com/hayasilin/unit-tests-ios-guide/blob/master/README.md)

這是總結我的開發經驗後所寫的的iOS單元測試規範，並包含使用Swift寫的單元測試範例程式碼。

我們一定都知道如何寫1個單元測試，但如何在1個有著多個iOS開發者共同合作的iOS專案中，寫出足夠的單元測試則是完全不同的事。
其中一種常見的情況是，你的團隊或是團隊經理希望有更高的程式覆蓋率，來確保iOS專案裡的程式碼在每次程式碼變更時，有被單元測試保護以維持良好的程式品質。

所以我想藉著此規範，來試著回答2問題：

- **如何在有多個iOS開發者共同合作的iOS專案中寫單元測試?**
- **iOS開發裡多少才是好的程式碼覆蓋率?**

此規範只是我個人的經驗總結，並不代表裡面所有規範都適合你的團隊，你可以參考並選擇其中適合你團隊的規範。

此外，本規範並沒有包含TDD(Test Driven Development)的內容。

最後，在我另一個Repo裡有實作一個模擬真實世界的iOS專案，來展示如何在iOS專案裡寫單元測試，並達到更高的程式碼覆蓋率，參考完此規範後也可以參考[此iOS專案](https://github.com/hayasilin/unit-tests-ios-demo-project/blob/master/README_zh-Hant.md)。

## 參考資料

這裡是幫助我完成此規範的參考資料，如果有這裡內容沒提到的細節，那就在以下的文件裡：

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

## 目錄
- [介紹](#介紹)
- [3種驗證原則](#3種驗證原則)
  - [驗證回傳值](#驗證回傳值)
  - [驗證狀態](#驗證狀態)
  - [驗證互動](#驗證互動)
- [基礎測試替身與Swift](#基礎測試替身與Swift)
  - [基礎測試替身被測試的類別](#基礎測試替身被測試的類別)
  - [基礎測試替身單元測試程式碼](#基礎測試替身單元測試程式碼)
- [進階測試替身與Swift](#進階測試替身與Swift)
  - [進階測試替身被測試的類別](#進階測試替身被測試的類別)
  - [進階測試替身單元測試程式碼](#進階測試替身單元測試程式碼)
- [iOS app開發模式分析](#ios-app開發模式分析)
  - [MVC](#mvc)
  - [MVVMC](#mvvmc)
- [我們應該在哪些程式碼上寫單元測試](#我們應該在哪些程式碼上寫單元測試)
  - [有些程式碼不一定需要寫單元測試](#有些程式碼不一定需要寫單元測試)
  - [公開與私用方法](#公開與私用方法)
- [有關程式碼覆蓋率](#有關程式碼覆蓋率)
- [程式碼覆蓋率與Xcode](#程式碼覆蓋率與Xcode)
- [多少才是良好的程式碼覆蓋率](#多少才是良好的程式碼覆蓋率)
- [總結](#總結)
- [Appendix](#appendix)
    - [Xcode keyboard shortcut for testing](#xcode-keyboard-shortcut-for-testing)
    - [UI類別的單元測試](#UI類別的單元測試)

## 介紹

**首先，此規範會示範如何在iOS專案裡使用Swift寫單元測試。**

我將介紹如何使用3種驗證原則來寫單元測試。

我也會示範如何使用**測試替身**產生**模仿物件**來達成測試孤立，使單元測試能覆蓋大多數的邏輯並避免Flaky tests。
此外，使用測試替身可以幫助測試你的模組與Apple或第三方的SDK之間的互動。

**此規範的第2部分，我將探討iOS專案裡的程式碼覆蓋率。**

程式碼覆蓋率是非常重要的，它幫助你的團隊知道在每次的程式變更中，有多少比例的程式碼在單元測試的保護之下。

我將探討Xcode中程式碼覆蓋率的組成，以及它與單元測試及UI測試之間的關係。

如果你想知道更多在Xcode裡的UI測試，可以參考我的另一篇文章[iOS及Android UI自動化測試規範](https://github.com/hayasilin/ios-android-ui-automation-tests-guide/blob/master/README_zh-hant.md)。

## 3種驗證原則

### 驗證回傳值

**被測試的方法**

```swift
func configureDataToEven(_ data: [String]?) -> [String]? {
    guard var data = data else { return nil }
        if data.count % 2 != 0 {
            data.removeLast()
        }
    return data
}
```

**單元測試程式碼**

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

### 驗證狀態

**被測試的方法**

```swift
var isSuccess: Bool = false

let dataManager = DataManager()

func saveData(_ data: [String]?) {
    let result = dataManager.save(data)
    isSuccess = result
}
```

**單元測試程式碼**

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

### 驗證互動

**單元測試程式碼**

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
- 上方的程式碼範例雖然可以執行測試，但有個問題假設ApiClient()是真的去執行API請求，那這個測試將會受限於請求的結果，假設Server端正好有問題或是正在部署，則可能請求會失敗，測試也會失敗，此方式同時也違反了**測試孤立化**的原則，因此更好的方式應該使用**測試替身**，詳見下方的程式碼以及[基礎測試替身與Swift章節](#基礎測試替身與Swift)
- 有關與Server端的Network請求與回覆相關測試，在測試光譜上應屬於整合測試(Integration Tests)而非單元測試，可以詳見我另一個文章[API自動化測試規範](https://github.com/hayasilin/api-automation-tests-guide/blob/master/README_zh-hant.md)

**單元測試程式碼**

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

## 基礎測試替身與Swift

測試替身能有效幫助單元測試孤立化，你可以用測試替身來測試與API互動的方法而不用真的去呼叫API來確保測試孤立。

**測試替身可分為3類：**
- **Stubs:** 模擬物件回傳所需的資料，來驗證目標物件行為是否如同預期。
- **Mocks:** 驗證目標物件是否正確的與相依物件進行互動。
- **Fakes:** 當目標物件較為複雜，需要為測試情境另外處理，透過建立目標物件的簡化版本的方式，直接模擬相依物件的行為。

想知道以下範例程式碼的更多資訊，可以參考Dr. Dominik Hauser的：[Test-Driven iOS Development with Swift 4](https://www.amazon.com/Test-Driven-iOS-Development-Swift-maintainable/dp/1788475704)。

### 基礎測試替身被測試的類別

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

### 基礎測試替身單元測試程式碼

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

## 進階測試替身與Swift

如果想要測試你的程式碼與Apple或第三方SDK的互動是比較困難的，因為你無法控制它們會給你什麼資料，但透過測試替身，你可以做到可控制的環境來測試雙方之間的互動。

以下範例示範如何測試你的模組與Apple的Core Location框架互動。

如果想知道以下範例程式碼的更多資訊，可以參考2018 WWDC session [Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/)。

### 進階測試替身被測試類別

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

### 進階測試替身單元測試程式碼

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

## iOS app開發模式分析

我們了解如何用Swift寫單元測試後，下一步我們需要分析在iOS專案裡，哪些部分真正需要寫單元測試。

### MVC

在App開發的時代，伺服器端跟客戶端都扮演重要角色。客戶端如App需要透過API跟伺服器端請求資料，接著理想上大多數的人是用MVC模式來建構他們的App。
我們知道邏輯和商業邏輯需要寫單元測試來涵蓋，所以類別像API Client，Models, 以及Controllers，我們需要對它們寫單元測試。

對於View的類別，在MVC模式下它們並不負責處理邏輯，所以與其寫單元測試，我們應該是寫UI測試來涵蓋，這部分我會在後面的章節解釋更多。

但在iOS開發世界，iOS的MVC模式跟傳統上我們認知的MVC模式是不同的。

如同各位所知，iOS使用UIViewController來執行Controller跟View的任務，這在小型iOS專案上是很直覺，但在大型iOS專案下卻會造成問題。
因為在大型iOS專案，你會得到1個龐大UIViewController類別，它有上千行的程式碼，造成很難去隨意更動程式碼。
更糟糕的是，裡面邏輯及商業邏輯的程式碼與View相關的程式碼混雜在一起，很難將他們分開，更別提對裡面的邏輯或商業邏輯寫單元測試。

為了解決這個問題，近幾年iOS世界提出了新的設計模式，如MVVMC或VIPER。
以下我會以MVVMC為例說明。

### MVVMC

MVVMC是一個由Model，View，ViewModel，以及Coordinator組成的模式。

透過MVVMC，我們使用1個類別稱為ViewModel，由它來負責邏輯及商業邏輯的任務，並透過data binding來與UIViewController溝通。

現在，UIViewController在分類上屬於UI，不該再有任何邏輯相關的程式碼。
如此一來，我們能將邏輯及UI清楚分開，我們知道應該對ViewModel寫單元測試，而對於UIViewController的類別，我們可以寫UI測試來涵蓋。

如何寫單元測試的配方開始逐漸明顯，我們應該對API Client，Managers，Helpers，資料庫相關的類別，以及Model等類別寫單單元測試。
而其他像UIView，UITableViewCell，UICollectionViewCell，或是處理UI動畫的類別，我們應該寫UI測試來涵蓋他們。

另外，MVVMC裡面還有Coordinator類別，它負責畫面的轉換，雖然畫面的轉換可能大多跟UI有關，但其中也可能有部分邏輯存在，可以針對有邏輯的部分寫單元測試，而對UI部分寫UI測試。

這個針對邏輯及商業邏輯的類別寫單元測試，對UI相關的類別寫UI測試的概念，不僅能應用在iOS開發上，同樣概念也能應用在Android開發上。

當然，現實世界凡事都有例外。如果現實情況讓你不得已讓UI類別擁有邏輯相關的程式碼，你仍然可以對UI類別寫單元測試，前提是你可以將UI類別裡的邏輯程式碼與其他程式碼清楚分開。

## 我們應該在哪些程式碼上寫單元測試

### 有些程式碼不一定需要寫單元測試

雖然我們想涵蓋越多程式碼越好，但是現實世界上總是有程式碼很難去覆蓋，或是你不需花時間為了它們去寫單元測試，因為可能不是那麼需要。

- iOS系統的返回(Callback)，如果裡面沒有需要驗證的邏輯。
- UI及View相關的類別，他們應只負責畫面的呈現。
- **更多...**（現實世界不是所有事情都完美，同樣程式碼也是）

### 公開與私用方法

你應該只需對1個類別裡的公開方法寫單元測試。

理論上，當你的單元測試涵蓋該類別裡的所有公開方法，那麼該類別裡的所有私用方法也應該被覆蓋了，因為私用方法是被公開方法所使用。

如果仍然有私用方法沒被覆蓋，你可能需要確認程式碼並嘗試重構，讓私用方法在公開方法被測試時，同時被涵蓋。

## 有關程式碼覆蓋率

我們都知道程式碼覆蓋率，但當我們在一個iOS專案中，有多個iOS開發者共同開發時，事情開始變得複雜起來。
然後你的團隊或團隊經理開始要求程式碼覆蓋率，為了確保在每次程式碼變動時，程式的品質有受到單元測試的保護。

接著的問題是在iOS專案中，多少的程式碼覆蓋率是我們的目標？像是100%的程式碼覆蓋率嗎？但這有可能達到嗎。
這部分沒有教科書可以給我們答案，特別在iOS開發的世界裡，所以我們需要自己來定義。

當開始寫單元測試時，有個問題一直被我的團隊提起，就是**我們應該為UI相關的類別寫單元測試嗎？**

App並不是像Server一樣是單純的邏輯應用程式，App有很大的任務是需要顯示UI，為了顯示UI需要很多的程式碼來建構，事實上，UI相關的程式碼數量在App裡佔大多數的比例。因此，如果你的程式碼覆蓋率中沒有包含UI相關的類別，你的程式碼覆蓋率的數字應該不會很高。

當然，現實上有很多方法讓我們不用管UI相關的類別，但仍然保有高程式碼覆蓋率。
比如說，最常見的方法是我們只計算那些有邏輯及商業邏輯的類別的程式碼覆蓋率，我們不去計算UI類別的部分。

但是，這真的能解答我們的問題，並保證我們的程式碼在每次的程式碼變動下都有被保護嗎？

更糟的是，有時程式碼覆蓋率只會變成數字遊戲。你可以只計算那些有被單元測試保護的類別，並忽略那些沒寫單元測試的類別，來得到很高的程式碼覆蓋率，即使那些沒寫單元測試的類別裡有包含到邏輯或商業邏輯。

單元測試及程式碼覆蓋率不能100%保證我們的App不會有任何缺陷，但它提供開發者一個快速的反饋來確認我們在每次程式碼的變動中，沒有造成破壞。

為了得到單元測試及程式碼覆蓋率在iOS專案的最佳實踐，接下來我將探討Xcode是如何幫助我們寫單元測試，以及產生程式碼覆蓋率的報告。

## 程式碼覆蓋率與Xcode

當我們在Xcode執行單元測試時，我們可以看到那些有邏輯或商業邏輯，並寫上單元測試的類別的程式碼覆蓋率。

當然我們的UI類別並不會有任何程式碼覆蓋率，因為裡面沒有邏輯或商業邏輯相關的程式碼，所以我們沒有對它們寫任何的單元測試。

但是，如果我們寫UI測試，我們將會看到程式碼覆蓋率出現在這些UI類別中。因為UI測試代表這些UI的程式碼有被執行到，所以也會被計算在裡面。

如此一來，我們清楚了解了在Xcode裡程式碼覆蓋率的概念，它不僅包含那些有寫單元測試的類別，也可以涵蓋到UI相關的類別，只要我們寫UI測試。

概念上，我們應該對有邏輯及商業邏輯的類別寫單元測試，針對UI相關的類別，我們需要寫UI測試來涵蓋它們，以得到整體性的程式碼覆蓋率報告。

如果你想知道更多有關Xcode的UI測試，你可以參考我的[iOS及Android UI自動化測試規範](https://github.com/hayasilin/ios-android-ui-automation-tests-guide/blob/master/README_zh-hant.md).

<img src="https://github.com/hayasilin/unit-tests-ios-guide/blob/master/resources/xcode_code_coverage.png">

## 多少才是良好的程式碼覆蓋率

我們知道單元測試是程式碼覆蓋率中重要的一環，但現在我們也知道App裡面的大多數的程式碼是UI相關的程式碼，所以我們需要寫UI測試來涵蓋它們。

但是，如同[測試三角形(Testing pyramid)](https://github.com/hayasilin/ios-android-ui-automation-tests-guide/blob/master/README_zh-hant.md#%E9%81%B5%E5%BE%9E%E6%B8%AC%E8%A9%A6%E4%B8%89%E8%A7%92%E5%BD%A2)告訴我們，我們不會對所有的UI都寫UI測試，我們的UI測試只需涵蓋最重要的使用者情境。所以有些部分的UI類別不會被涵蓋，比如像是錯誤顯示頁面。

此外，在大型App專案中，有些程式碼不容易寫單元測試來涵蓋，或是你的團隊需要額外的成本來特別針對某些程式碼寫單元測試。
比如你的App裡有使用一些iOS系統的返回(Callback)，但裡面沒有明顯的邏輯需要去驗證，或是有一些Legacy code，可能需要先重構程式碼，才能開始寫單元測試。

在現實世界中，一切並不總是完美。

我的經驗是遵從這個規範，在5位iOS開發者的團隊中，以及敏捷開發的環境裡，可以持續維持程式碼覆蓋率達60%左右。

如果想達到程式碼覆蓋率在每次的程式碼變更中，維持在70%左右也是有機會的，但首先需要需要確認所有你的團隊成員遵守這個規範，而且他們不僅寫單元測試，也需要寫UI測試。

我並沒有在大型iOS專案中讓程式碼覆蓋率一直維持在80%左右的經驗。我推測為了達到這個數字，你的團隊需要付出很多額外的資源及時間，且需不斷地確認所有程式碼每行都有被涵蓋到，即使有些程式碼並不一定需要被涵蓋。

在現實中，大多數的開發團隊都被商業計劃及新功能推著跑，並沒有多餘的時間付出額外的資源，所以你的團隊需要三思，並在團隊資源與程式碼覆蓋率之間取得平衡，以正確的設定屬於你的團隊的程式碼覆蓋率的目標。

總結來說，在iOS專案裡，如果你的團隊還不熟悉單元測試，測試替身，或是UI測試，提升至40% ~ 50%的程式碼覆蓋率是可以先設定的目標。

如果你的團隊熟悉單元測試及UI測試，並開始遵守此規範，可以把目標設定在每次程式碼變動時，程式碼覆蓋率持續維持在 **60% ~ 70%** 左右，我認為對團隊來說，這即是良好的程式碼覆蓋率，因為這個資訊足以提供團隊足夠的信心，我們知道即使每次程式碼變更，大多數的程式碼有被單元測試保護，也可避免投入過多的資源只為了追求更高的數字。

大部分的資源應該是放在更重要的事，如新功能開發。

## 總結

- 使用3種驗證原則來寫單元測試。
- 使用測試替身來孤立要測試的物件。
- 中大型iOS專案裡請使用MVVMC(或是VIPER)，而非使用MVC。
- 只需測試公開方法，理論上當你測試公開方法時，所有私用方法應該同時也都被測試到。如果有私用方法仍沒被單元測試覆蓋，可能代表你需要重構你的程式碼。
- 有些程式碼可能不需要寫單元測試，請放置不管。
- 首先對包含邏輯及商業邏輯的類別寫單元測試，再來對UI類別寫UI測試。
- 在團隊資源與程式碼覆蓋率之間取得平衡，以正確的設定屬於你的團隊的程式碼覆蓋率的目標。

## Appendix

### Xcode keyboard shortcut for testing
- Run the test: ⌘ U
- Run only one test: ctrl ⌥ ⌘ U
- Re-run the previous set of tests: - ctrl ⌥ ⌘ G

### UI類別的單元測試

根據Dr. Dominik Hauser的[Test-Driven iOS Development with Swift 4](https://www.amazon.com/Test-Driven-iOS-Development-Swift-maintainable/dp/1788475704)，還是有對UI類別寫單元測試的方法，個人雖非完全同意我們需要對UI類別寫單元測試，但如果你的iOS專案因現實因素，UI類別裡也有邏輯或商業邏輯，或是iOS專案無法擁有UI測試，仍可參考Dr. Dominik Hauser書中的方式測試如UIViewController等其他UI類別。

以下程式碼僅供參考。

**被測試類別**

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

**測試程式碼**

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
