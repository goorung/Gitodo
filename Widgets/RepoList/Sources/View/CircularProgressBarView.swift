//
//  CircularProgressBarView.swift
//  GitodoRepoListWidget
//
//  Created by jiyeon on 5/22/24.
//

import SwiftUI

struct CircularProgressBarView: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 7.0
    var size: CGFloat = 50.0
    var progressColor: Color
    var trackColor: Color = Color.init(uiColor: .systemGray5)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}
