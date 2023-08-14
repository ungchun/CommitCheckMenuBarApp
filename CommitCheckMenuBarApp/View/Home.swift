//
//  Home.swift
//  CommitCheckMenuBarApp
//
//  Created by Kim SungHun on 2023/08/14.
//

import SwiftUI

struct Home: View {
	
	@State var currentTab: String = "test1"
	@Namespace var animation
	
    var body: some View {
		VStack {
			CustomSegmentdControl()
				.padding()
			
			Spacer()
			
			Text("")
			
			Spacer()
			
			HStack {
				Button {
					
				} label: {
					Image(systemName: "gearshape.fill")
				}
				
				Spacer()
				
				Button {
					
				} label: {
					Image(systemName: "power")
				}
			}
			.padding(.horizontal)
			.padding(.vertical, 10)
			.background(Color.black)
		}
		.frame(width: 320, height: 450)
		.background(Color("BG"))
		.preferredColorScheme(.dark)
		.buttonStyle(.plain)
    }
	
	@ViewBuilder
	func CustomSegmentdControl() -> some View {
		HStack(spacing: 0) {
			ForEach(["test1", "test2"], id:\.self) { tab in
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
