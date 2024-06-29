//
//  ContentView.swift
//  IntegratingCoreImage
//
//  Created by Víctor Ávila on 28/06/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins // Helpers to make loading easier
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
//        image = Image(.example)
        
        // Creating an UIImage from our example image and manipulating it using CoreImage
        // 1. Load our image into an UIImage with the initializer, which will return a value
        // 2. Convert the value into CIImage, which is what CoreImage wants to work with
        let inputImage = UIImage(resource: .example)
        let beginImage = CIImage(image: inputImage)
        
        // Creating a CoreImageContext and a CoreImageFilter
        // Filters are things that transform image data somehow, such as blurring it, sharpening it or changing the color somehow
        // Context handle all that information and converts it into a processed CGImage we can work with (it runs a recipe)
        // Both of these data types come from CoreImage
        // We will add a Sepia tone filter
        let context = CIContext()
//        let currentFilter = CIFilter.sepiaTone() // Load that filter ready to use
//        let currentFilter = CIFilter.pixellate()
//        let currentFilter = CIFilter.crystallize()
        let currentFilter = CIFilter.twirlDistortion()
        
        // We can customize the way the filter works
        // Sepia has only two properties we care about: one is the input image (the image we want to change in our recipe) and the other is intensity (how strong the Sepia should be applied, from 0 to 1)
        currentFilter.inputImage = beginImage
//        currentFilter.intensity = 1 // Maximum strength Sepia effect
        
        // Convert the output of the filter into a SwiftUI Image we can display in our View
        // The easiest thing to do is to read the output image from our filter (a CIImage? which could fail);
        // Ask our context to convert the output image (a CIImage?) into a CGImage? (also could fail);
        // Convert the CGImage? into an UIImage;
        // Convert the UIImage into a SwiftUI Image.
        
        // CoreImage is a little bit "creative". It was introduced 12 years ago. Its API was the least Swifty thing for a long time.
        // For instance, pixellating has to be done by setting a scale, not an intensity:
//        currentFilter.scale = 100
        // And crystallizing has to be done by setting a radius, not a scale:
//        currentFilter.radius = 300
        // twirlDistortion, however, can be set by a radius:
//        currentFilter.radius = 1000
//        currentFilter.center = CGPoint(x: inputImage.size.width/2, y: inputImage.size.height/2)
        
        // However, for this project we're going to use the older API because it lets us set values dynamically
        // We can ask the filter what it supports and then send the value on
        let amount = 1.0 // Some unknown number
        let inputKeys = currentFilter.inputKeys // Read the things it actually supports
        if inputKeys.contains(kCIInputIntensityKey) { // If this is a filter that supports intensity
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) { // If this is a filter that supports radius
            currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) { // If this is a filter that supports scale
            currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)
        }
        // These kCI*** are just magic strings behind the scenes.
        // If you're implementing precise CoreImage adjustments, please use the new API with exact property names and types.
        // In this particular project we will switch between many different kinds of filters very quickly, so that's why we will use the old API.
        
        // You can go directly from a CGImage to a SwiftUI Image (skiping one step), but it requires extra parameters which add more complexities
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return } // Use the whole information of the outputImage
        let uiImage = UIImage(cgImage: cgImage)
        image = Image(uiImage: uiImage)
        
    }
}

#Preview {
    ContentView()
}
