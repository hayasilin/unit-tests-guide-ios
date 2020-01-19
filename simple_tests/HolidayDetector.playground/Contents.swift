import UIKit
import Foundation
import XCTest

// Reference: https://www.amazon.co.jp/iOS%E3%82%A2%E3%83%97%E3%83%AA%E9%96%8B%E7%99%BA%E8%87%AA%E5%8B%95%E3%83%86%E3%82%B9%E3%83%88%E3%81%AE%E6%95%99%E7%A7%91%E6%9B%B8%E3%80%9CXCTest%E3%81%AB%E3%82%88%E3%82%8B%E5%8D%98%E4%BD%93%E3%83%86%E3%82%B9%E3%83%88%E3%83%BBUI%E3%83%86%E3%82%B9%E3%83%88%E3%81%8B%E3%82%89%E3%80%81CI-CD%E3%80%81%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E6%8A%80%E8%A1%93%E3%81%BE%E3%81%A7-%E5%B9%B3%E7%94%B0-%E6%95%8F%E4%B9%8B/dp/4297106299

func isHoliday(date: Date = Date()) -> Bool {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: date)
    return weekday == 1 || weekday == 7
}

isHoliday()

class HolidayDetectorTests: XCTestCase {
    func testIsHolidayTrue() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        var date: Date!

        // Sunday
        date = formatter.date(from: "2019/01/06")
        XCTAssertTrue(isHoliday(date: date))

        // Saturday
        date = formatter.date(from: "2019/01/12")
        XCTAssertTrue(isHoliday(date: date))
    }

    func testIsHolidayFalse() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        var date: Date!

        // Monday
        date = formatter.date(from: "2019/01/07")
        XCTAssertFalse(isHoliday(date: date))

        // Friday
        date = formatter.date(from: "2019/01/11")
        XCTAssertFalse(isHoliday(date: date))
    }
}

HolidayDetectorTests.defaultTestSuite.run()

// Use mock object

protocol DateProtocol {
    func now() -> Date
}

class DateDefault: DateProtocol {
    func now() -> Date {
        return Date()
    }
}

class CalendarUtil {
    let dateProtocol: DateProtocol

    init(dateProtocol: DateProtocol = DateDefault()) {
        self.dateProtocol = dateProtocol
    }

    func isHoliday() -> Bool {
        let now = dateProtocol.now()

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)

        return weekday == 1 || weekday == 7
    }
}

let isHoliday = CalendarUtil().isHoliday()

struct MockDateProtocol: DateProtocol {
    var date: Date? = nil

    func now() -> Date {
        return date!
    }
}

class CalendarUtilTests: XCTestCase {
    func testIsHoliday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        var mock = MockDateProtocol()

        // Sunday
        mock.date = formatter.date(from: "2019/01/06")
        XCTAssertTrue(CalendarUtil(dateProtocol: mock).isHoliday())

        // Monday
        mock.date = formatter.date(from: "2019/01/07")
        XCTAssertFalse(CalendarUtil(dateProtocol: mock).isHoliday())

        // Friday
        mock.date = formatter.date(from: "2019/01/11")
        XCTAssertFalse(CalendarUtil(dateProtocol: mock).isHoliday())

        // Saturday
        mock.date = formatter.date(from: "2019/01/12")
        XCTAssertTrue(CalendarUtil(dateProtocol: mock).isHoliday())
    }
}

CalendarUtilTests.defaultTestSuite.run()
