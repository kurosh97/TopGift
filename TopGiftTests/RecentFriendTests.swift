/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
@testable import TopGift
import CoreData

class RecentFriendServiceTests: XCTestCase {
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var recentFriendService: RecentFriendService!
    var coreDataStack: CoreDataStack!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        recentFriendService = RecentFriendService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        recentFriendService = nil
        coreDataStack = nil
    }
    
    func testAddRecentFriend() {
        // 1
        let recentFriend = recentFriendService.add(age: "21", email: "michalo@metorpolia.fi", fullName: "Michael", gender: "male", homeTown: "Espoo", phoneNum: "52019512", profileImage: UIImage(named: "defaultPhoto")?.jpegData(compressionQuality: 0.75))
        
        // 2
        XCTAssertNotNil(recentFriend, "New friend should not be nil")
        XCTAssertTrue(recentFriend.age == "21")
        XCTAssertTrue(recentFriend.email == "michalo@metorpolia.fi")
        XCTAssertTrue(recentFriend.fullName == "Michael")
        XCTAssertTrue(recentFriend.gender == "male")
        XCTAssertTrue(recentFriend.homeTown == "Espoo")
        XCTAssertTrue(recentFriend.phoneNum == "52019512")
        XCTAssertNotNil(recentFriend.profileImage, "profileImage should not be nil")
    }
    
    
    func testRootContextIsSavedAfterAddingRecentFriend() {
        // 1
        let derivedContext = coreDataStack.newDerivedContext()
        recentFriendService = RecentFriendService(
            managedObjectContext: derivedContext,
            coreDataStack: coreDataStack)
        
        // 2
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: coreDataStack.mainContext) { _ in
            return true
        }
        
        // 3
        derivedContext.perform {
            let recentFriend = self.recentFriendService.add(age: "23", email: "testi@metorpolia.fi", fullName: "Testi", gender: "female", homeTown: "Vantaa", phoneNum: "021512512", profileImage: UIImage(named: "defaultPhoto")?.jpegData(compressionQuality: 0.75))
            
            XCTAssertNotNil(recentFriend)
        }
        
        // 4
        waitForExpectations(timeout: 15.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testGetRecentFriends() {
        let recentFriend = recentFriendService.add(age: "21", email: "michalo@gmail.com", fullName: "Michael Lock", gender: "male", homeTown: "Espoo", phoneNum: "8008135", profileImage: UIImage(named: "profile1")?.jpegData(compressionQuality: 0.85))
        
        let getRecentFriends = recentFriendService.getRecentFriends()
        
        XCTAssertNotNil(getRecentFriends)
        XCTAssertTrue(getRecentFriends?.count == 1)
        XCTAssert(recentFriend.id == getRecentFriends?.first?.id)
    }
    
    func testUpdateRecentFriend() {
        let recentFriend = recentFriendService.add(age: "89", email: "matti.meikalainen@luukku.fi", fullName: "Matti Meikalainen", gender: "äijä", homeTown: "Savo", phoneNum: "0343152", profileImage: UIImage(named: "profile2")?.jpegData(compressionQuality: 0.85))
        
        recentFriend.age = "54"
        recentFriend.email = "matti.jaaskelainen@luukku.fi"
        recentFriend.fullName = "Matti Jaaskelainen"
        recentFriend.gender = "miäs"
        recentFriend.homeTown = "Sipoo"
        recentFriend.phoneNum = "09823523"
        recentFriend.profileImage = UIImage(named: "profile1")?.jpegData(compressionQuality: 0.85)
        
        let updatedReport = recentFriendService.update(recentFriend)
        
        XCTAssertTrue(recentFriend.id == updatedReport.id)
        XCTAssertTrue(recentFriend.email == updatedReport.email)
        XCTAssertTrue(recentFriend.fullName == updatedReport.fullName)
        XCTAssertTrue(recentFriend.gender == updatedReport.gender)
        XCTAssertTrue(recentFriend.homeTown == updatedReport.homeTown)
        XCTAssertTrue(recentFriend.phoneNum == updatedReport.phoneNum)
        XCTAssertNotNil(recentFriend.profileImage, "profileImage should not be nil")
    }
    
    func testDeleteRecentFriend() {
        let recentFriend = recentFriendService.add(age: "23", email: "matti.meikalainen@luukku.fi", fullName: "Matti Meikalainen", gender: "äijä", homeTown: "Savo", phoneNum: "0343152", profileImage: UIImage(named: "profile2")?.jpegData(compressionQuality: 0.85))
        
        var fetchRecentFriends = recentFriendService.getRecentFriends()
        XCTAssertTrue(fetchRecentFriends?.count == 1)
        XCTAssertTrue(recentFriend.id == fetchRecentFriends?.first?.id)
        
        recentFriendService.delete(recentFriend)
        
        fetchRecentFriends = recentFriendService.getRecentFriends()
        
        XCTAssertTrue(fetchRecentFriends?.isEmpty ?? false)
    }
}
