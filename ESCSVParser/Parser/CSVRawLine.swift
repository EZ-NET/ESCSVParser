//
//  CSVRawLine.swift
//  ESCSVParser
//
//  Created by Tomohiro Kumagai on H27/07/15.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

/// This struct will be used at the time of parsing.
/// This struct treats each column as raw string value in a row.
/// By using 'column(index:Int)' method, you can convert the value of raw column data to any type that conforms to 'RawColumnConvertible' protocol.
/// An optional<T:RawColumnConvertible> type is also conforms to 'RawColumnConvertible' protocol.
public struct RawLine {
	
	var columns:[RawColumn]
	
	init(columns:RawColumn...) {
		
		self.init(columns: columns)
	}
	
	init(columns:[RawColumn]) {
		
		self.columns = columns
	}
	
	init(rawLine line:String) throws {
		
		self.columns = try CSVParser.parseRawLine(line).columns
	}
}

extension RawLine : CollectionType {
	
	public var startIndex:Int {
		
		return self.columns.startIndex + 1
	}
	
	public var endIndex:Int {
		
		return self.columns.endIndex + 1
	}
	
	public subscript(index:Int) -> RawColumn {
		
		return self.columns[index - 1]
	}
}

extension RawLine {

	static func column<R:RawColumnConvertible where R == R.ConvertedType>(rawColumn:RawColumn) throws -> R {
		
		let isNilLiteralConvertibleType = R.self is NilLiteralConvertible.Type
		let isRawColumnNullableType = R.self is RawColumnNullable.Type
		
		if isNilLiteralConvertibleType && isRawColumnNullableType {
			
			if (R.self as! RawColumnNullable.Type).isRawColumnNull(rawColumn) {
				
				return (R.self as! NilLiteralConvertible.Type).init(nilLiteral: ()) as! R
			}
		}
		
		do {
			
			return try R.fromRawColumn(rawColumn)
		}
		catch let error as FromRawColumnError {

			let message = "Failed to convert column type from 'String'(\(rawColumn)) to '\(R.self)'."
			let reasonSuffix = error.reason.map { " \($0)" } ?? ""
			
			throw CSVParserError.ConvertError(message + reasonSuffix)
		}
	}
	
	/// Returns an any type that conforms to 'RawColumnConvertible' protocol that converted from raw column string at 'index'.
	public func column<R:RawColumnConvertible where R == R.ConvertedType>(index:Int) throws -> R {
		
		return try RawLine.column(self[index]) as R
	}
}
