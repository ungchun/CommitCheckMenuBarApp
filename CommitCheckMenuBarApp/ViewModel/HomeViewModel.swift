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
	
	@Published var isAccessTokenState: Bool = UserDefaultsSetting.username == "" ? false : true
	@Published var allCommitValue: String?
	@Published var accumulateCommitValue: Int?
	@Published var todayCommit: Bool?
	
	init() {
		let urlAddress = "https://github.com/ungchun"
		
		guard let url = URL(string: urlAddress) else { return }
		
		do {
			let html = try String(contentsOf: url, encoding: .utf8)
			let doc: Document = try SwiftSoup.parse(html)
			
			let commits: Elements = try doc.select(".ContributionCalendar-day").select("span")
			
			let allCommit: Elements = try doc.select(".position-relative").select("h2")
			
			let commitsText = try commits.text()
			
			let allCommitText = try allCommit.text()
			
			if let regex = try? NSRegularExpression(pattern: "\\d+") {
				let matches = regex.matches(in: allCommitText,
											range: NSRange(allCommitText.startIndex...,
														   in: allCommitText))
				let numbers = matches.map { match in
					String(allCommitText[Range(match.range, in: allCommitText)!])
				}
				
				if let numberString = numbers.first, let number = Int(numberString) {
					print("Extracted number:", number)
				}
			}
			
			let parseCommitData = parseCommitData(from: commitsText)
			
			allCommitValue = String(parseCommitData.0.totalSum)
			todayCommit = parseCommitData.0.todayCommit ? true : false
			accumulateCommitValue = parseCommitData.1
		} catch {
			print("Error reading HTML: \(error)")
		}
	}
	
	func requestAccessToken(with code: String) {
		var name = ""
		let url = "https://github.com/login/oauth/access_token"
		let parameters = ["client_id": ClientID,
						  "client_secret": ClientSecret,
						  "code": code]
		
		let headers: HTTPHeaders = ["Accept": "application/json"]
		
		AF.request(url, method: .post, parameters: parameters,
				   headers: headers).responseJSON { (response) in
			switch response.result {
			case let .success(json):
				if let dic = json as? [String: String] {
					self.updateGitHubUserInfo(token: dic["access_token"]!) { result in
						let getName = result["name"] as? String
						name = getName!
						UserDefaultsSetting.username = name
					}
				}
			case let .failure(error):
				print(error)
			}
		}
		isAccessTokenState = true
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
				case .failure(_): break
				}
			}
	}
	
	func parseCommitData(from input: String) -> (CommitData, Int) {
		let lines = input.split(separator: "\n")
		var todayCommitStreak = 0
		var stringArr: [[String]] = []
		var tempYearMonthDay: [String] = []
		for line in lines {
			var cnt = 0
			let components = line.split(separator: " ")
			
			let monthMap: [String: String] = [
				"January": "01", "February": "02", "March": "03", "April": "04",
				"May": "05", "June": "06", "July": "07", "August": "08",
				"September": "09", "October": "10", "November": "11", "December": "12"
			]
			
			components.forEach { string in
				tempYearMonthDay.append(String(describing: string))
				cnt += 1
				if cnt == 7 {
					var tempFormattedDates: [String] = []
					
					cnt = 0
					
					let month = tempYearMonthDay[4]
					let day = tempYearMonthDay[5].replacingOccurrences(of: ",", with: "")
					let year = tempYearMonthDay[6]
					
					let monthNumber = monthMap[month] ?? "01"
					
					var formattedDay = day
					if day.count == 1 {
						formattedDay = "0" + day
					}
					
					let formattedDate = "\(year)-\(monthNumber)-\(formattedDay)"
					
					tempFormattedDates.append(formattedDate)
					
					if tempYearMonthDay[0] == "No" {
						tempFormattedDates.append("0")
					} else {
						tempFormattedDates.append(tempYearMonthDay[0])
					}
					
					stringArr.append(tempFormattedDates)
					tempYearMonthDay = []
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
		}
		
		let totalSum = stringArr.reduce(0) { $0 + (Int($1[1]) ?? 0) }
		return (CommitData(totalSum: totalSum,
						   todayCommit: stringArr.first?.last == "0" ? false : true),
				todayCommitStreak)
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
}
