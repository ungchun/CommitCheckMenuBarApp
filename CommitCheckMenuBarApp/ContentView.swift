//
//  ContentView.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI
import Alamofire
import SwiftSoup

struct ContentView: View {
	
	@StateObject var viewModel: HomeViewModel
	
	let clientID = "6f121e037458424660e6"
	let scope = "repo gist user"
	@State var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
	
	var body: some View {
		VStack {
			Link("Login with Github",
				 destination: components.url!)
			.onOpenURL { url in
				let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
				requestAccessToken(with: code)
			}
		}
		.onAppear {
			components.queryItems = [
				URLQueryItem(name: "client_id", value: self.clientID),
				URLQueryItem(name: "scope", value: self.scope),
			]
			
		}
		.padding()
	}
}
