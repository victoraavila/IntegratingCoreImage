//
//  ContentView.swift
//  IntegratingCoreImage
//
//  Created by Víctor Ávila on 28/06/24.
//

import SwiftUI

// CoreImage is an Apple framework for editing existing images (not drawing): sharpening, blurs, vignettes, pixelation, etc.
// It is largely used in the Photo Booth app
// However, it does not integrate with SwiftUI neither UIKit well

// 0. Add the image to assets catalog
// 1. Create the Image view as an Optional @State property
// 2. Resize to fill the screen
// 3. Add a .onAppear() modifier to actually load the image

struct ContentView: View {
    // Notice how smoothly SwiftUI deals with Optional views
    // Also notice that image is a view, because ultimately it is something we can display (we can't for example write it to disk or apply transformations beside applying SwiftUI image filters).
    @State private var image: Image?
    
    // If you're going to use CoreImage, SwiftUI Image view is a great endpoint, but it is not useful if we want to create images dynamically or apply CoreImage filters.
    // We have 3 more image types to work with, and we have to master them in order to use CoreImage:
    // 1. UIImage, from UIKit, can handle working with a variety of image types like .png, vector images and image sequences that form animations. It's the standard image type for UIKit and the closest to SwiftUI Image.
    // 2. CGImage, from CoreGraphics, is simpler than UIKit and it is just a 2D array of pixels.
    // 3. CIImage, from CoreImage, stores the information required to produce a picture rather than pixels. It's an image recipe that only turn it into pixels if asked to.
    // We can make an UIImage from a CGImage, and we can make a CGImage from an UIImage.
    // We can make a CIImage from an UIImage and from a CGImage.
    // We can make a CGImage from a CIImage.
    // We can make a SwiftUI Image from an UIImage and from a CGImage.
    // These 3 types are pure data: they hold image information and therefore we cannot place them into a SwiftUI View hierarchy. We can manipulate them freely, then present results in a SwiftUI View. They're great for times you want to manipulate data before showing it on screen somehow.
    
    var body: some View {
        // The VStack triggers the .onAppear() modifier, because by default the image is going to be nil
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        image = Image(.example)
    }
}

#Preview {
    ContentView()
}
