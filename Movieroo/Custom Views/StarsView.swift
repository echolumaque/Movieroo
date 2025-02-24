//
//  StarsView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import SwiftUI

struct StarsView: View {
    @State var model: StarRatingModel
    
    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<model.maxRating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
            }
        }

        stars.overlay {
            GeometryReader { geometry in
                let width = model.rating / CGFloat(model.maxRating) * geometry.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        }
        .foregroundColor(.gray.opacity(0.3))
    }
}

@Observable
final class StarRatingModel {
    var rating: CGFloat
    @ObservationIgnored let maxRating: Int

    init(rating: CGFloat = 0, maxRating: Int = 5) {
        self.rating = rating
        self.maxRating = maxRating
    }
}
