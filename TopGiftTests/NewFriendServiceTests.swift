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

class NewFriendServiceTests: XCTestCase {
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var newFriendService: NewFriendService!
    var coreDataStack: CoreDataStack!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        newFriendService = NewFriendService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        newFriendService = nil
        coreDataStack = nil
    }
    
    func testAddNewFriend() {
        // 1
        let newFriend = newFriendService.add(age: "21", email: "michalo@metorpolia.fi", fullName: "Michael", gender: "male", homeTown: "Espoo", phoneNum: "52019512", profileImage: UIImage(named: "defaultPhoto")?.jpegData(compressionQuality: 0.75))
        
        // 2
        XCTAssertNotNil(newFriend, "New friend should not be nil")
        XCTAssertTrue(newFriend.age == "21")
        XCTAssertTrue(newFriend.email == "michalo@metorpolia.fi")
        XCTAssertTrue(newFriend.fullName == "Michael")
        XCTAssertTrue(newFriend.gender == "male")
        XCTAssertTrue(newFriend.homeTown == "Espoo")
        XCTAssertTrue(newFriend.phoneNum == "52019512")
        XCTAssertNotNil(newFriend.profileImage, "profileImage should not be nil")
    }
    
    
    func testRootContextIsSavedAfterAddingNewFriend() {
        // 1
        let derivedContext = coreDataStack.newDerivedContext()
        newFriendService = NewFriendService(
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
            let newFriend = self.newFriendService.add(age: "23", email: "testi@metorpolia.fi", fullName: "Testi", gender: "female", homeTown: "Vantaa", phoneNum: "021512512", profileImage: UIImage(named: "defaultPhoto")?.jpegData(compressionQuality: 0.75))
            
            XCTAssertNotNil(newFriend)
        }
        
        // 4
        waitForExpectations(timeout: 15.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    func testGetNewFriends() {
        let newFriend = newFriendService.add(age: "21", email: "michalo@gmail.com", fullName: "Michael Lock", gender: "male", homeTown: "Espoo", phoneNum: "8008135", profileImage: UIImage(named: "profile1")?.jpegData(compressionQuality: 0.85))
        
        let getNewFriends = newFriendService.getNewFriends()
        
        XCTAssertNotNil(getNewFriends)
        XCTAssertTrue(getNewFriends?.count == 1)
        XCTAssert(newFriend.id == getNewFriends?.first?.id)
    }
    
    func testUpdateNewFriend() {
        let newFriend = newFriendService.add(age: "89", email: "matti.meikalainen@luukku.fi", fullName: "Matti Meikalainen", gender: "äijä", homeTown: "Savo", phoneNum: "0343152", profileImage: UIImage(named: "profile2")?.jpegData(compressionQuality: 0.85))
        
        newFriend.age = "54"
        newFriend.email = "matti.jaaskelainen@luukku.fi"
        newFriend.fullName = "Matti Jaaskelainen"
        newFriend.gender = "miäs"
        newFriend.homeTown = "Sipoo"
        newFriend.phoneNum = "09823523"
        newFriend.profileImage = UIImage(named: "profile1")?.jpegData(compressionQuality: 0.85)
        
        let updatedReport = newFriendService.update(newFriend)
        
        XCTAssertTrue(newFriend.id == updatedReport.id)
        XCTAssertTrue(newFriend.email == updatedReport.email)
        XCTAssertTrue(newFriend.fullName == updatedReport.fullName)
        XCTAssertTrue(newFriend.gender == updatedReport.gender)
        XCTAssertTrue(newFriend.homeTown == updatedReport.homeTown)
        XCTAssertTrue(newFriend.phoneNum == updatedReport.phoneNum)
        XCTAssertNotNil(newFriend.profileImage, "profileImage should not be nil")
    }
    
    func testDeleteNewFriend() {
        let newFriend = newFriendService.add(age: "23", email: "matti.meikalainen@luukku.fi", fullName: "Matti Meikalainen", gender: "äijä", homeTown: "Savo", phoneNum: "0343152", profileImage: UIImage(named: "profile2")?.jpegData(compressionQuality: 0.85))
        
        var fetchNewFriends = newFriendService.getNewFriends()
        XCTAssertTrue(fetchNewFriends?.count == 1)
        XCTAssertTrue(newFriend.id == fetchNewFriends?.first?.id)
        
        newFriendService.delete(newFriend)
        
        fetchNewFriends = newFriendService.getNewFriends()
        
        XCTAssertTrue(fetchNewFriends?.isEmpty ?? false)
    }
}
