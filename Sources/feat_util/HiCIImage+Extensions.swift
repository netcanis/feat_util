//
//  HiCIImage+Extensions.swift
//  feat_util
//
//  Created by netcanis on 12/22/24.
//

import CoreImage
import UIKit

public extension CIImage {
    /// Rotates the image by the specified degrees.
    /// - Parameter degrees: The rotation angle in degrees.
    /// - Returns: A new rotated `CIImage`.
    func hiRotate(by degrees: CGFloat) -> CIImage {
        guard degrees != 0.0 else { return self }

        let radians = degrees * .pi / 180
        let originalWidth = self.extent.width
        let originalHeight = self.extent.height

        let transform = CGAffineTransform(translationX: originalWidth / 2, y: originalHeight / 2)
            .rotated(by: radians)
            .translatedBy(x: -originalWidth / 2, y: -originalHeight / 2)

        return self.transformed(by: transform)
    }

    /// Crops the image to a region defined by camera coordinates.
    /// - Parameters:
    ///   - roiRect: The region of interest in screen coordinates.
    ///   - screenSize: The size of the screen.
    /// - Returns: A cropped `CIImage`.
    func hiCropToCameraCoordinates(roiRect: CGRect, screenSize: CGSize) -> CIImage {
        let cameraWidth = self.extent.width
        let cameraHeight = self.extent.height

        let widthScale = cameraWidth / screenSize.width
        let heightScale = cameraHeight / screenSize.height
        let minScale = min(widthScale, heightScale)

        let cropHeight = roiRect.height * minScale
        let cropWidth = cropHeight * 1.586
        let cropOriginX = (cameraWidth - cropWidth) / 2
        let cropOriginY = cameraHeight - (roiRect.origin.y + roiRect.height) * minScale

        let scaledScanBox = CGRect(
            x: cropOriginX,
            y: cropOriginY,
            width: cropWidth,
            height: cropHeight
        )

        return self.cropped(to: scaledScanBox)
    }

    /// Resizes the image to fit the specified target size while maintaining aspect ratio.
    /// - Parameter targetSize: The target size for the image.
    /// - Returns: A resized `CIImage`.
    func hiResizeToFit(targetSize: CGSize) -> CIImage {
        let originalWidth = self.extent.width
        let originalHeight = self.extent.height
        let widthRatio = targetSize.width / originalWidth
        let heightRatio = targetSize.height / originalHeight
        let scale = min(widthRatio, heightRatio)

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let resizedImage = self.transformed(by: transform)
        let centeredX = (targetSize.width - resizedImage.extent.width) / 2.0
        let centeredY = (targetSize.height - resizedImage.extent.height) / 2.0

        return resizedImage.transformed(by: CGAffineTransform(translationX: centeredX, y: centeredY))
    }

    /// Resizes the image to fill the specified target size while maintaining aspect ratio.
    /// - Parameter targetSize: The target size for the image.
    /// - Returns: A resized and cropped `CIImage`.
    func hiResizeToFill(targetSize: CGSize) -> CIImage {
        let originalWidth = self.extent.width
        let originalHeight = self.extent.height
        let widthScale = targetSize.width / originalWidth
        let heightScale = targetSize.height / originalHeight
        let scale = max(widthScale, heightScale)

        let scaledImage = self.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let scaledExtent = scaledImage.extent

        let cropOriginX = max((scaledExtent.width - targetSize.width) / 2.0, 0)
        let cropOriginY = max((scaledExtent.height - targetSize.height) / 2.0, 0)
        let cropRect = CGRect(x: cropOriginX, y: cropOriginY, width: targetSize.width, height: targetSize.height)
        
        // Crop and return the final image
        guard scaledExtent.contains(cropRect) else {
            return scaledImage
        }
        return scaledImage.cropped(to: cropRect)
    }

    /// Converts the `CIImage` to a `UIImage`.
    /// - Returns: A `UIImage` representation of the `CIImage`.
    func hiConvertToUIImage() -> UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: self.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    /// Converts the image to grayscale.
    /// - Returns: A grayscale `CIImage`, or `nil` if the operation fails.
    func hiApplyGrayscale() -> CIImage? {
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(self, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove colors (grayscale)
        grayscaleFilter?.setValue(1.0, forKey: kCIInputContrastKey)   // Maintain default contrast
        grayscaleFilter?.setValue(0.0, forKey: kCIInputBrightnessKey) // Maintain default brightness
        return grayscaleFilter?.outputImage
    }

    /// Applies a Gaussian blur to reduce noise in the image.
    /// - Parameter radius: The blur radius (default is 2.0).
    /// - Returns: A blurred `CIImage`.
    func hiApplyGaussianBlur(radius: Double = 2.0) -> CIImage? {
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            print("Failed to create CIGaussianBlur filter")
            return self
        }
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        
        return filter.outputImage?.cropped(to: self.extent)
    }

    /// Emphasizes text using a color matrix for thresholding.
    /// - Parameter threshold: The threshold value to emphasize text (default is 0.5).
    /// - Returns: A thresholded `CIImage`.
    func hiEmphasizeTextUsingColorMatrix(threshold: Float = 0.5) -> CIImage? {
        guard let colorMatrixFilter = CIFilter(name: "CIColorMatrix") else {
            print("Failed to create CIColorMatrix filter")
            return self
        }

        colorMatrixFilter.setValue(self, forKey: kCIInputImageKey)

        let scaleValue = 1.0 / (1.0 - CGFloat(threshold))
        let biasValue = -CGFloat(threshold) * scaleValue

        // Set channel transformation vectors
        let scaleVector = CIVector(x: scaleValue, y: scaleValue, z: scaleValue, w: 0)
        let biasVector = CIVector(x: biasValue, y: biasValue, z: biasValue, w: 0)

        colorMatrixFilter.setValue(scaleVector, forKey: "inputRVector")
        colorMatrixFilter.setValue(scaleVector, forKey: "inputGVector")
        colorMatrixFilter.setValue(scaleVector, forKey: "inputBVector")
        colorMatrixFilter.setValue(biasVector, forKey: "inputBiasVector")
        colorMatrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")

        return colorMatrixFilter.outputImage
    }

    /// Analyzes the image to adjust contrast and brightness.
    /// - Returns: A `CIImage` with optimized brightness and contrast, or `nil` if the operation fails.
    func hiAnalyzeAndAdjust() -> CIImage? {
        let meanFilter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: self,
            kCIInputExtentKey: CIVector(cgRect: self.extent)
        ])

        guard let outputImage = meanFilter?.outputImage else {
            print("Failed to apply mean filter")
            return self
        }

        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        let r = Int(bitmap[0])
        let g = Int(bitmap[1])
        let b = Int(bitmap[2])

        let brightness = 0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b)
        let isBrightBackground = brightness > 192
        let contrastFactor = hiCalculateContrastFactor(minBrightness: Int(brightness), maxBrightness: 255)
        let brightnessOffset = hiCalculateBrightnessOffset(averageBrightness: brightness, isBrightBackground: isBrightBackground)

        let adjustedImage = hiAdjustContrastAndBrightness(
            contrastFactor: contrastFactor,
            brightnessOffset: brightnessOffset
        ) ?? self
        
        return isBrightBackground ? hiInvertColors() : adjustedImage
    }

    /// Adjusts the contrast and brightness of the image.
    private func hiAdjustContrastAndBrightness(contrastFactor: Float, brightnessOffset: Int) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(self, forKey: kCIInputImageKey)
        filter?.setValue(contrastFactor, forKey: "inputContrast")
        filter?.setValue(Float(brightnessOffset) / 255.0, forKey: "inputBrightness")
        return filter?.outputImage
    }

    /// Inverts the colors of the image.
    /// - Returns: A color-inverted `CIImage`.
    func hiInvertColors() -> CIImage? {
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(self, forKey: kCIInputImageKey)
        return filter?.outputImage ?? self
    }

    /// Calculates the contrast factor based on brightness range.
    private func hiCalculateContrastFactor(minBrightness: Int, maxBrightness: Int) -> Float {
        let range = maxBrightness - minBrightness
        return range > 0 ? Float(255) / Float(range) : 1.0
    }

    /// Calculates the brightness offset based on average brightness and background brightness.
    private func hiCalculateBrightnessOffset(averageBrightness: Double, isBrightBackground: Bool) -> Int {
        return isBrightBackground ? -15 : Int(128 - averageBrightness)
    }
}

