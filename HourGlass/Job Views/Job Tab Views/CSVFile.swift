//
//  CSVFile.swift
//  HourGlass
//
//  Created by Sam Cook on 24/06/2025.
//


import SwiftUI
import UniformTypeIdentifiers

struct CSVFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var text = ""

    init(initialText: String = "") {
        self.text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}