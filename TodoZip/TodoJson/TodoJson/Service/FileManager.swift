//
//  FileManager.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/23/25.
//

import Foundation

// MARK: - 3. FileManager
extension FileManager {
    
    static func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getTodoFileURL(for userId: String) -> URL {
        return getDocumentDirectory().appendingPathComponent("\(userId)_todo.json")
    }
    
    static func saveJSON<T: Encodable>(_ data: T, to url: URL) throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData = try encoder.encode(data)
            
            try jsonData.write(to: url, options: .atomic)
            
            print("🟢 파일 저장 성공: \(url.lastPathComponent)")
        } catch {
            print("🔴 파일 저장 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func loadJSON<T: Decodable>(from url: URL, as type: T.Type) throws -> T {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedData = try decoder.decode(type, from: data)
            return decodedData
        } catch {
            print("🔴 파일 로드 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    @discardableResult
    static func deleteFile(at url: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("🟢 파일 삭제 성공: \(url.lastPathComponent)")
                return true
            } else {
                print("🔴 삭제할 파일이 없음: \(url.lastPathComponent)")
                return false
            }
        } catch {
            print("🔴 파일 삭제 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
}
