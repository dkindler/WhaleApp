//
//  HomeViewController.swift
//  WhaleApp
//
//  Created by Dan Kindler on 12/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    // Properties
    let recordBarHeight: CGFloat = 10
    let recordButtonColor = UIColor(white: 0.2, alpha: 0.7)
    var outputUrls = [URL]()
    var recordIndicatorView: ProgressIndicatiorView?
    var recordButton = UIButton()
    
    // Camera Management Properties
    let captureSession = AVCaptureSession()
    let videoFileOutput = AVCaptureMovieFileOutput()
    var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var microphone: AVCaptureDevice?

    // Nav Bar Buttons
    var nextButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCamera()
        setupIndicatorView()
        setupRecordButton()
    }

    //MARK: - UI Setup
    
    private func setupNavigationBar() {
        nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPressed))
        nextButton?.isEnabled = false
        let reset = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPressed))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        self.navigationItem.setLeftBarButton(reset, animated: true)
    }
    
    private func setupCamera() {
        frontCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        backCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        microphone = AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone, mediaType: AVMediaTypeAudio, position: .unspecified)
        if let frontCamera = frontCamera, let microphone = microphone {
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: frontCamera))
                try captureSession.addInput(AVCaptureDeviceInput(device: microphone))
                
                cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                cameraPreviewLayer.frame = view.bounds
                view.layer.addSublayer(cameraPreviewLayer)
                captureSession.startRunning()
                captureSession.addOutput(videoFileOutput)
                
                let connection = videoFileOutput.connection(withMediaType: AVMediaTypeVideo)
                connection?.videoOrientation = .portrait
            } catch _ {
            }
        }
    }
    
    private func setupRecordButton() {
        let recordButtonHeight: CGFloat = 100
        let yAxis: CGFloat = view.bounds.height - recordButtonHeight - 30
        let xAxis: CGFloat = (view.bounds.width / 2) - (recordButtonHeight / 2)
        recordButton = UIButton(frame: CGRect(x: xAxis, y: yAxis, width: recordButtonHeight, height: recordButtonHeight))
        recordButton.backgroundColor = recordButtonColor
        recordButton.addTarget(self, action: #selector(recordHoldStarted(sender:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordHoldStopped(sender:)), for: .touchDragExit)
        recordButton.addTarget(self, action: #selector(recordHoldStopped(sender:)), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    private func setupIndicatorView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let height: CGFloat = (navigationController?.navigationBar.bounds.height ?? 0) + statusBarHeight
        recordIndicatorView = ProgressIndicatiorView(frame: CGRect(x: 0, y: height, width: view.bounds.width, height: recordBarHeight))
        if let recordIndicatorView = recordIndicatorView {
            recordIndicatorView.delegate = self
            view.addSubview(recordIndicatorView)
        }
    }
    
    //MARK: - Actions

    func recordHoldStarted(sender: UIButton) {
        guard let recordIndicatorView = recordIndicatorView, !recordIndicatorView.hasReachedMaxRecordTime else { return }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("\(String.randomString(length: 6)).mp4")
        
        videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
        animateStartRecording()
    }
    
    func recordHoldStopped(sender: UIButton) {
        videoFileOutput.stopRecording()
        animateStopRecording()
    }
    
    func nextPressed() {
        let watchVc = WatchViewController()
        watchVc.outputUrls = outputUrls
        self.navigationController?.show(watchVc, sender: self)
    }
    
    func resetPressed() {
        videoFileOutput.stopRecording()
        outputUrls = [URL]()
        nextButton?.isEnabled = false
        recordIndicatorView?.reset()
    }
    
    func animateStartRecording() {
        UIView.animate(withDuration: 0.5, animations: {
            // Make the red circle into a square
            self.recordButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.recordButton.layer.cornerRadius = self.recordButton.bounds.width/2
            self.recordButton.backgroundColor = whaleColor
        }, completion: nil)
    }
    
    func animateStopRecording() {
        UIView.animate(withDuration: 0.5, animations: {
            // Make square back into a circle
            self.recordButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.recordButton.layer.cornerRadius = 0
            self.recordButton.backgroundColor = self.recordButtonColor
        }, completion: nil)
    }
}


// MARK: - AVCapture Recording Delegate
extension HomeViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        recordIndicatorView?.startProgressBarProgression()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        outputUrls.append(outputFileURL)
        recordIndicatorView?.endProgressBarProgression()
    }
}

// MARK: - ProgressIndicatiorView Delegate

extension HomeViewController: ProgressIndicatiorViewDelegate {
    func hasReachedMaxRecordTime(sender: ProgressIndicatiorView) {
        videoFileOutput.stopRecording()
    }
    
    func hasReachedMinimumRecordTime(sender: ProgressIndicatiorView) {
        nextButton?.isEnabled = true
    }
}











