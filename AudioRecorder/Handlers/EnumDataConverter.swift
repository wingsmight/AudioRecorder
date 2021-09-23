//
//  EnumDataConverter.swift
//  AudioRecorder
//
//  Created by Igoryok on 23.09.2021.
//

import Foundation


func encode<T>(var value: T) -> NSData {
    return withUnsafePointer(&value) { p in
        NSData(bytes: p, length: MemoryLayout.size(ofValue: value))
    }
}

func decode<T>(data: NSData) -> T {
    let pointer = UnsafeMutablePointer<T>.alloc(MemoryLayout.size(ofValue: T.Type))
    data.getBytes(pointer)
    
    return pointer.move()
}
