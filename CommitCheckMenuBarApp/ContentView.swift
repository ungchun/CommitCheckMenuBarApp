//
//  ContentView.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI
import Alamofire
import SwiftSoup

let ClientID = ""
let ClientSecret = ""

struct ContentView: View {
	
	@StateObject var viewModel: HomeViewModel
	
	@State var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
	
	let scope = "repo gist user"
	
	var body: some View {
		VStack {
			Link("Login with Github",
				 destination: components.url!)
			.onOpenURL { url in
				let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
				viewModel.requestAccessToken(with: code)
			}
		}
		.onAppear {
			components.queryItems = [
				URLQueryItem(name: "client_id", value: ClientID),
				URLQueryItem(name: "scope", value: self.scope),
			]
		}
		.padding()
	}
}
