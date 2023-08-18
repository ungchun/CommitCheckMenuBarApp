//
//  UserDefaultsSetting.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/17.
//

import Foundation

enum UserDefaultsSetting {
	
	@UserDefaultsWrapper(key: "username", defaultValue: "")
	static var username
}
