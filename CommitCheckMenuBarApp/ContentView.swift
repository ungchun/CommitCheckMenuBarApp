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
	
	// 여기서 값을 받아서 popover HomeView로 넘긴다..?
	
	@StateObject var viewModel: HomeViewModel
	
	let clientID = ""
	let scope = "repo gist user"
	@State var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
	
	var body: some View {
		VStack {
			Link("Login with Github",
				 destination: components.url!)
			.onOpenURL { url in
//				print("url = \(url)")
				let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
//				print("code = \(code)")
				
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


func requestAccessToken(with code: String) {
	let url = "https://github.com/login/oauth/access_token"
	let parameters = ["client_id": "",
					  "client_secret": "",
					  "code": code]
	
	let headers: HTTPHeaders = ["Accept": "application/json"]
	
	AF.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
		switch response.result {
		case let .success(json):
			if let dic = json as? [String: String] {
				print(dic["access_token"]!)
				print(dic["scope"]!)
				print(dic["token_type"]!)
				
//				fetchCommitHistory(token: dic["access_token"]!, for: "ungchun") { event, err in
//					if let error = err {
//						print("Error fetching commit history: \(error)")
//						return
//					}
//
//					if let events = event {
//						print(events)
//					}
//				}
			}
		case let .failure(error):
			print(error)
		}
	}
}

//func fetchCommitHistory(token: String, for username: String, completion: @escaping ([CommitEvent]?, Error?) -> Void) {
//	let urlString = "https://api.github.com/users/\(username)/events"
//
//	guard let url = URL(string: urlString) else {
//		completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
//		return
//	}
//
//	var request = URLRequest(url: url)
//	request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
//
//	let task = URLSession.shared.dataTask(with: request) { data, response, error in
//		if let error = error {
//			completion(nil, error)
//			return
//		}
//
//		guard let data = data else {
//			completion(nil, NSError(domain: "No data received", code: -1, userInfo: nil))
//			return
//		}
//
//		do {
//			let events = try JSONDecoder().decode([CommitEvent].self, from: data)
//			completion(events, nil)
//		} catch {
//			completion(nil, error)
//		}
//	}
//	task.resume()
//}

//struct CommitEvent: Codable {
//	let type: String
//	let payload: Payload
//
//	struct Payload: Codable {
//		let commits: [Commit]
//
//		struct Commit: Codable {
//			let sha: String
//			let message: String
//			let author: Author
////			let since: String
//
//			struct Author: Codable {
//				let name: String
//				let email: String
//			}
//		}
//	}
//}
