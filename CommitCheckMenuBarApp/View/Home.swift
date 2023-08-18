//
//  Home.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI

struct Home: View {
	
	@State var currentTab: String = "TODAY"
	@Namespace var animation
	
	@StateObject var viewModel: HomeViewModel = .init()
	
	var body: some View {
		if currentTab == "TODAY" {
			mainView()
		} else {
			mainView2()
		}
		
		//		if UserDefaultsSetting.username == "" {
		//			// github api로 username 가져와서 세팅
		//		} else {
		//			if currentTab == "test1" {
		//				mainView()
		//			} else {
		//				mainView2()
		//			}
		//		}
	}
	
	@ViewBuilder
	func mainView() -> some View {
		VStack {
			CustomSegmentdControl()
				.padding()
			
			Spacer()
				.frame(height: 60)
			
			HStack {
				Text("TODAY COMMIT ...")
					.font(.custom("Partial-Sans-KR", size: 20))
					.padding(.leading, 20)
				Spacer()
			}
			
			Spacer()
				.frame(height: 40)
			
			if viewModel.todayCommit! {
				Text("CLEAR")
					.font(.custom("Partial-Sans-KR", size: 65))
			} else {
				Text("NOT YET")
					.font(.custom("Partial-Sans-KR", size: 65))
			}
			
			Spacer()
		}
		.frame(width: 320, height: 450)
		.background(Color("BG"))
		.preferredColorScheme(.dark)
		.buttonStyle(.plain)
	}
	
	@ViewBuilder
	func mainView2() -> some View {
		VStack {
			CustomSegmentdControl()
				.padding()
			
			Spacer()
				.frame(height: 40)
			
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					
					Text("ungchun")
						.font(.custom("Partial-Sans-KR", size: 20))
						.padding(.leading, 20)
					
					Spacer()
						.frame(height: 50)
					
					HStack {
						Text("\(viewModel.textValue!)")
							.font(.custom("Partial-Sans-KR", size: 40))
						Text("COMMIT")
							.font(.custom("Partial-Sans-KR", size: 15))
					}
					.padding(.leading, 40)
					
					Spacer()
						.frame(height: 50)
					
					HStack {
						Text("Continuous")
							.font(.custom("Partial-Sans-KR", size: 10))
						Text("\(viewModel.todayCommitValue!)")
							.font(.custom("Partial-Sans-KR", size: 70))
						Text("DAY")
							.font(.custom("Partial-Sans-KR", size: 20))
					}
					.padding(.leading, 30)
					

				}
				
				Spacer()
				
				// 0.75, 0.5, 0.25
				GaugeView(filledRatio: 1.0)
					.frame(width: 20, height: 200)
					.padding(.trailing, 20)
			}
			
			Spacer()
			
		}
		.frame(width: 320, height: 450)
		.background(Color("BG"))
		.preferredColorScheme(.dark)
		.buttonStyle(.plain)
	}
	
	@ViewBuilder
	func CustomSegmentdControl() -> some View {
		HStack(spacing: 0) {
			ForEach(["TODAY", "ALL"], id:\.self) { tab in
				Text(tab)
					.fontWeight(currentTab == tab ? .semibold : .regular)
					.foregroundColor(currentTab == tab ? .white : .gray)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 6)
					.background {
						if currentTab == tab {
							RoundedRectangle(cornerRadius: 8, style: .continuous)
								.fill(Color("TAB"))
								.matchedGeometryEffect(id: "TAB", in: animation)
						}
					}
					.contentShape(Rectangle())
					.onTapGesture {
						withAnimation {
							currentTab = tab
						}
					}
			}
		}
		.padding()
		.background {
			Color.black
				.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
		}
	}
}

struct GaugeView: View {
	let filledRatio: CGFloat
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottom) {
				Rectangle()
					.frame(width: geometry.size.width, height: geometry.size.height)
					.foregroundColor(Color.gray.opacity(0.2))
				
				Rectangle()
					.frame(width: geometry.size.width, height: geometry.size.height * self.filledRatio)
					.foregroundColor(Color.blue)
			}
		}
	}
}
