import XCTest

class Holiday {
    func isTodayChristmas() -> String {
        let today = getToday()

        if today.contains("12") && (today.contains("24") || today.contains("25")) {
            return "Merry Christmas"
        } else {
            return "Not X'mas"
        }
    }

    func getToday() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
}

class HolidayTests: XCTestCase {
    let sut = MockHoliday()

    func testIsChristmasDec24() {
        sut.setToday(today: "2019/12/24")
        resultShouldBe(expected: "Merry Christmas")
    }

    func testIsChristmasDec25() {
        sut.setToday(today: "2019/12/25")
        resultShouldBe(expected: "Merry Christmas")
    }

    func testIsNotChristmas() {
        sut.setToday(today: "2019/12/23")
        resultShouldBe(expected: "Not X'mas")
    }

    func resultShouldBe(expected: String) {
        XCTAssertEqual(expected, sut.isTodayChristmas())
    }

    class MockHoliday: Holiday {
        private var today: String = ""

        func setToday(today: String) {
            self.today = today
        }

        override func getToday() -> String {
            return today
        }
    }
}
HolidayTests.defaultTestSuite.run()

let holiday = Holiday()
holiday.isTodayChristmas()
