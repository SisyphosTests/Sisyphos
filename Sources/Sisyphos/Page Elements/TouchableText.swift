import Foundation
import UIKit
import XCTest

/// Identified as the static text, but it also supports tapping on a specific part of the full text by calling
/// the custom ``tapOn(text:file:line:onFailure:)`` function.
public struct TouchableText: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let text: String

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .staticText,
            identifier: nil,
            label: text,
            value: nil,
            descendants: []
        )
    }

    public init(
        identifier: String? = nil,
        _ text: String,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.text = text
    }

    @discardableResult
    /// Call this function if you would need to tap on some sort of slice inside the full text.
    /// - Parameters:
    ///   - text: Sliced text that will be searched in the full text element.
    ///   - onFailure: A closure that is called when finding the position of sliced text fails.
    /// - Returns: Boolean value that indicates whether tapping on the sliced part is succeeded.
    public func tapOn(text: String,
                      file: StaticString = #file,
                      line: UInt = #line,
                      onFailure: (String, StaticString, UInt) -> Void = XCTFail) -> Bool {
        guard let calculatedPosition = textPosition(slicedText: text) else {
            onFailure("Given chunk (\(text)) couldn't find in the text component", file, line)
            return false
        }
        tap(usingPosition: calculatedPosition)
        return true
    }
}

// MARK: - Helpers

private extension TouchableText {
    /// A helper function which will be called to determine the point representation of the starting location of
    /// the sliced text given in the arguments.
    /// - Parameters:
    ///   - slicedText: Some part of the text in the element which will be searched.
    ///   - withFont: As the position is dependent on the text size, this argument will be used for determining
    ///   the precise location of the given text.
    /// - Returns: An optional `CGPoint` which specifies the starting point of the given text.
    func textPosition(slicedText: String, withFont: UIFont = UIFont.systemFont(ofSize: 14)) -> CGPoint? {
        let range: NSRange = (self.text as NSString).range(of: slicedText)
        let prefix = (self.text as NSString).substring(to: range.location)
        let size: CGSize = prefix.size(withAttributes: [.font: withFont])
        let point = CGPoint(x: size.width, y: 0)
        return point
    }
}
