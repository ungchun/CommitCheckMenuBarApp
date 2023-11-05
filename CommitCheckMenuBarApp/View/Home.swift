//
//  Home.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI

struct Home: View {
	
	@StateObject var viewModel: HomeViewModel = .init()
	
	@State var currentTab: String = "TODAY"
	@Namespace var animation
	
	var body: some View {
		if !viewModel.isAccessTokenState {
			VStack {
				Text("Fetch")
					.onTapGesture {
						viewModel.isAccessTokenState = UserDefaultsSetting.username == "" ? false : true
					}
			}
			.frame(width: 320, height: 450)
			.background(Color("BG"))
			.preferredColorScheme(.dark)
			.buttonStyle(.plain)
		} else {
			if currentTab == "TODAY" {
				TodayView()
			} else {
				AllView()
			}
		}
	}
	
	@ViewBuilder
	func TodayView() -> some View {
		VStack {
			CustomSegmentdControl()
				.padding()
			
			Spacer()
			
			Text("TODAY COMMIT")
				.font(.custom("Partial-Sans-KR", size: 15))
			
			Spacer()
				.frame(height: 10)
			
			
			if viewModel.todayCommit! {
				Text("DONE\nDONE")
					.font(.custom("Partial-Sans-KR", size: 75))
			} else {
				Text("NOT\nYET")
					.font(.custom("Partial-Sans-KR", size: 80))
			}
			
			Spacer()
		}
		.frame(width: 320, height: 450)
		.background(Color("BG"))
		.preferredColorScheme(.dark)
		.buttonStyle(.plain)
	}
	
	@ViewBuilder
	func AllView() -> some View {
		VStack(spacing: 0) {
			CustomSegmentdControl()
				.padding()
			
			Spacer()
				.frame(height: 10)
			
			VStack(alignment: .leading) {
				Divider()
					.opacity(0)
				
				Text("\(UserDefaultsSetting.username)")
					.font(.custom("Partial-Sans-KR", size: 25))
				
				Spacer()
					.frame(height: 10)
				
				Text("COMMIT")
					.font(.custom("Partial-Sans-KR", size: 15))
				
				Spacer()
					.frame(height: 5)
				
				Text("\(viewModel.allCommitValue!)")
					.font(.custom("Partial-Sans-KR", size: 60))
				
				Spacer()
					.frame(height: 5)
				
				Text("Accumulate")
					.font(.custom("Partial-Sans-KR", size: 15))
				
				Spacer()
					.frame(height: 5)
				
				HStack {
					Text("\(viewModel.accumulateCommitValue!)")
						.font(.custom("Partial-Sans-KR", size: 70))
					Text("DAY")
						.font(.custom("Partial-Sans-KR", size: 20))
				}
				
			}
			.padding(.leading, 20)
			
			Spacer()
				.frame(height: 20)
			
			GaugeView(
				filledRatio:
					viewModel.accumulateCommitValue! == 0 ? 0.0 :
					viewModel.accumulateCommitValue! >= 1 ? 0.25 :
					viewModel.accumulateCommitValue! >= 8 ? 0.5 :
					viewModel.accumulateCommitValue! >= 15 ? 0.75 : 1.0)
			.frame(height: 20)
			.padding(.horizontal, 20)
			
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
			ZStack(alignment: .leading) {
				Rectangle()
					.frame(width: geometry.size.width, height: geometry.size.height)
					.foregroundColor(Color.gray.opacity(0.2))
				
				Rectangle()
					.frame(width: geometry.size.width * self.filledRatio, height: geometry.size.height)
					.foregroundColor(Color.white)
			}
		}
	}
}
