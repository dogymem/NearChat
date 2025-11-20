import XCTest
@testable import NearChat

final class NearChatTests: XCTestCase {

    var tcpManager: TCPManager!
    var appState: AppState!

    @MainActor override func setUpWithError() throws {
        tcpManager = TCPManager()
        appState = AppState()
    }

    override func tearDownWithError() throws {
        tcpManager = nil
        appState = nil
    }

    @MainActor func testMessageCreationFormat() throws {
        
        let nickname = "TestUser"
        let message = "Hello"
        
        
        let fullMessage = tcpManager.createFullMessage(message: message, nickname: nickname)
        
        
        
        let parts = fullMessage.split(separator: ":")
        XCTAssertEqual(parts.count, 3, "Сообщение должно состоять из 3 частей: Time:Nick:Msg")
    }

    
    @MainActor func testBase64Encoding() throws {
        
        let nickname = "User"
        let message = "Hello" 
        
        
        let fullMessage = tcpManager.createFullMessage(message: message, nickname: nickname)
        let parts = fullMessage.split(separator: ":")
        
        
        let encodedMsg = String(parts[2])
        XCTAssertEqual(encodedMsg, "SGVsbG8=", "Сообщение должно быть закодировано в Base64")
    }

    
    @MainActor func testSpecialCharacters() throws {
        
        let nickname = "User:Name" 
        let message = "Hi 👋"       
        
        
        let fullMessage = tcpManager.createFullMessage(message: message, nickname: nickname)
        let parts = fullMessage.split(separator: ":")
        
        
        
        let decodedNickData = Data(base64Encoded: String(parts[1]))!
        let decodedMsgData = Data(base64Encoded: String(parts[2]))!
        
        let decodedNick = String(data: decodedNickData, encoding: .utf8)
        let decodedMsg = String(data: decodedMsgData, encoding: .utf8)
        
        XCTAssertEqual(decodedNick, "User:Name", "Никнейм с двоеточием должен восстановиться корректно")
        XCTAssertEqual(decodedMsg, "Hi 👋", "Сообщение с эмодзи должно восстановиться корректно")
    }
}
