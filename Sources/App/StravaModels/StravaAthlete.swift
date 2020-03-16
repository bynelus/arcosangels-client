//
//  StravaAthlete.swift
//  App
//
//  Created by Niels Koole on 16/03/2020.
//

import Vapor

struct StravaAthlete: Content {
	let id: Int
	let firstname: String
	let lastname: String
}

