//
//  HomeViewModel.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import Foundation
import SwiftSoup
import Alamofire

final class HomeViewModel: ObservableObject {
	
	@Published var isAccessTokenState: Bool = false
	@Published var textValue: String?
	@Published var todayCommitValue: Int?
	@Published var todayCommit: Bool?
//	@Published var username: String?
	
	init() {
		let urlAddress = "https://github.com/ungchun"
		
		guard let url = URL(string: urlAddress) else { return }
		
		do {
			let html = try String(contentsOf: url, encoding: .utf8)
			let doc: Document = try SwiftSoup.parse(html)
			
			let title: Elements = try doc.select(".ContributionCalendar-day").select("span")
			
			let allCommit: Elements = try doc.select(".position-relative").select("h2")
			
			let text = try title.text() // UI 세팅
			
			let allCommitText = try allCommit.text() // UI 세팅
			print("allCommit \(allCommitText)")
			
			if let regex = try? NSRegularExpression(pattern: "\\d+") {
				let matches = regex.matches(in: allCommitText, range: NSRange(allCommitText.startIndex..., in: allCommitText))
				let numbers = matches.map { match in
					String(allCommitText[Range(match.range, in: allCommitText)!])
				}
				
				if let numberString = numbers.first, let number = Int(numberString) {
					print("Extracted number:", number)
				}
			}
			
//			textValue = allCommitText
			//				viewModel.change(val: "allCommitText")
			
//			let commitDataArray = parseCommitData(from: text)
			
			let cal = parseCommitData(from: text)
			
			textValue = String(cal.0.totalSum)
			todayCommit = cal.0.todayCommit ? true : false
			todayCommitValue = cal.1
			
//			for commitData in commitDataArray {
//				print("Date: \(commitData.date), Contributions: \(commitData.contributions)")
//			}
			
			// 이후 작업을 수행
		} catch {
			print("Error reading HTML: \(error)")
		}
	}
	
	
	@MainActor
	func change(val: String) {
		textValue = val
		print("!!! call")
	}
}


func requestAccessToken(with code: String) -> String {
	var name = ""
	let url = "https://github.com/login/oauth/access_token"
	let parameters = ["client_id": "6f121e037458424660e6",
					  "client_secret": "1011f631d3699763d6d21e9327888ec55bdae987",
					  "code": code]
	
	let headers: HTTPHeaders = ["Accept": "application/json"]
	
	AF.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
		switch response.result {
		case let .success(json):
			if let dic = json as? [String: String] {
				print(dic["access_token"]!)
				print(dic["scope"]!)
				print(dic["token_type"]!)
				
				updateGitHubUserInfo(token: dic["access_token"]!) { result in
					print("call \(result)")
					
					let getName = result["name"] as? String
					name = getName!
					print("name \(name)")
					
				}
			}
		case let .failure(error):
			print(error)
		}
	}
	return name
}

func updateGitHubUserInfo(token: String, completion: @escaping ([String: Any]) -> Void) {
	let urlString = "https://api.github.com/user"
	
	let headers: HTTPHeaders = [
		"Accept": "application/vnd.github+json",
		"Authorization": "Bearer \(token)",
	]
	
	AF.request(urlString, method: .patch, encoding: JSONEncoding.default, headers: headers)
		.responseJSON { response in
			switch response.result {
			case .success(let value):
				if let json = value as? [String: Any] {
					completion(json)
				} else { }
			case .failure(let error): break
			}
		}
}



struct CommitData {
//	let date: String
//	let contributions: Int
	
	let totalSum: Int
	let todayCommit: Bool
}

func parseCommitData(from input: String) -> (CommitData, Int) {
	let lines = input.split(separator: "\n")
	var commitDataArray: [CommitData] = []
	var todayCommitStreak = 0
	var stringArr: [[String]] = []
	var temp: [String] = []
//	print("lines = \(lines)")
	for line in lines {
		var cnt = 0
		let components = line.split(separator: " ")
		if let contributions = Int(components[0]), let date = components.last {
//			commitDataArray.append(CommitData(date: String(date), contributions: contributions))
		}
		
		let monthMap: [String: String] = [
			"January": "01", "February": "02", "March": "03", "April": "04",
			"May": "05", "June": "06", "July": "07", "August": "08",
			"September": "09", "October": "10", "November": "11", "December": "12"
		]
		
		components.forEach { string in
			temp.append(String(describing: string))
			cnt += 1
			if cnt == 7 {
				var temp2: [String] = []
				cnt = 0
				let month = temp[4]
				let day = temp[5].replacingOccurrences(of: ",", with: "")
				let year = temp[6]
				
				let monthNumber = monthMap[month] ?? "01"
				
				var formattedDay = day
				if day.count == 1 {
					formattedDay = "0" + day
				}
				
				let formattedDate = "\(year)-\(monthNumber)-\(formattedDay)"
				
				temp2.append(formattedDate)
				
				if temp[0] == "No" {
					temp2.append("0")
				} else {
					temp2.append(temp[0])
				}
				
				//				print()
				
				stringArr.append(temp2)
				temp = []
			}
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		stringArr.sort { (item1, item2) in
			if let date1 = dateFormatter.date(from: item1[0]),
			   let date2 = dateFormatter.date(from: item2[0]) {
				return date1 > date2
			}
			return false
		}

		todayCommitStreak = calculateConsecutiveCommitDays(commitData: stringArr)
		print("todayCommitStreak = \(todayCommitStreak)")
	}
	let totalSum = stringArr.reduce(0) { $0 + (Int($1[1]) ?? 0) }
	return (CommitData(totalSum: totalSum, todayCommit: stringArr.first?.last == "0" ? false : true), todayCommitStreak)
}

func calculateConsecutiveCommitDays(commitData: [[String]]) -> Int {

	var count = 0
	for data in commitData {
		if data.last == "0" {
			break
		}
		count += 1
	}

	return count
}
