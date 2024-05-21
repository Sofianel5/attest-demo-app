//
//  JsonRequest.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/21/24.
//

import Foundation

struct JsonRequest {
    private var httpBody = NSMutableData()
    let url: URL

    init(url: URL) {
        self.url = url
    }
}
