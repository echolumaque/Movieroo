//
//  CircularImageView.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/25/25.
//

import SwiftUI

struct CircularImageView: View {
    
    var url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
//            Image(.avatarPlaceholder)
//                .resizable()
//                .scaledToFit()
            ProgressView()
        }
        .clipShape(.circle)
    }
}
