import Flutter
import Photos
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let galleryChannelName = "com.dev.luminous/gallery"
  private var galleryChannel: FlutterMethodChannel?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let flutterViewController = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: galleryChannelName,
      binaryMessenger: flutterViewController.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleGalleryMethodCall(call, result: result)
    }
    galleryChannel = channel
  }

  private func handleGalleryMethodCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard call.method == "saveImage" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard
      let arguments = call.arguments as? [String: Any],
      let bytes = arguments["bytes"] as? FlutterStandardTypedData
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT",
          message: "bytes is required",
          details: nil
        )
      )
      return
    }

    let fileName = normalizedFileName(arguments["fileName"] as? String)

    requestPhotoLibraryPermission { [weak self] granted in
      guard granted else {
        result(
          FlutterError(
            code: "PERMISSION_DENIED",
            message: "Photo library permission denied",
            details: nil
          )
        )
        return
      }

      self?.saveImageToPhotoLibrary(
        data: bytes.data,
        fileName: fileName,
        result: result
      )
    }
  }

  private func normalizedFileName(_ fileName: String?) -> String {
    if let value = fileName?.trimmingCharacters(in: .whitespacesAndNewlines),
       !value.isEmpty {
      return value
    }
    return "luminous_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
  }

  private func requestPhotoLibraryPermission(
    completion: @escaping (Bool) -> Void
  ) {
    if #available(iOS 14, *) {
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      if status == .authorized || status == .limited {
        completion(true)
        return
      }
      if status == .denied || status == .restricted {
        completion(false)
        return
      }
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { nextStatus in
        DispatchQueue.main.async {
          completion(nextStatus == .authorized || nextStatus == .limited)
        }
      }
      return
    }

    let status = PHPhotoLibrary.authorizationStatus()
    if status == .authorized {
      completion(true)
      return
    }
    if status == .denied || status == .restricted {
      completion(false)
      return
    }
    PHPhotoLibrary.requestAuthorization { nextStatus in
      DispatchQueue.main.async {
        completion(nextStatus == .authorized)
      }
    }
  }

  private func saveImageToPhotoLibrary(
    data: Data,
    fileName: String,
    result: @escaping FlutterResult
  ) {
    var localIdentifier: String?

    PHPhotoLibrary.shared().performChanges({
      let creationRequest = PHAssetCreationRequest.forAsset()
      let options = PHAssetResourceCreationOptions()
      options.originalFilename = fileName
      creationRequest.addResource(with: .photo, data: data, options: options)
      localIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
    }) { success, error in
      DispatchQueue.main.async {
        if let error {
          result(
            FlutterError(
              code: "SAVE_FAILED",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }

        if success {
          result(localIdentifier)
          return
        }

        result(
          FlutterError(
            code: "SAVE_FAILED",
            message: "Unable to save image",
            details: nil
          )
        )
      }
    }
  }
}
