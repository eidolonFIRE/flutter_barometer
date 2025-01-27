import Flutter
import UIKit
import CoreMotion

public class SwiftFlutterBarometer: NSObject, FlutterPlugin, FlutterStreamHandler {
    var altimeter:CMAltimeter?
    var pressure:Double = 0.0
    var sinkOnChanged: FlutterEventSink?
    var listeningOnChanged = false
    
    override init() {
        super.init()
        altimeter = CMAltimeter()
        getCurrentPressure()
    }
    
    private func getCurrentPressure() {
        if(CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter!.startRelativeAltitudeUpdates(
                to: OperationQueue.main,
                withHandler:
                    {data, error in
                        if error == nil {
                            let pressure:Double = data!.pressure.doubleValue
                            //let altitude:Double = data!.relativeAltitude.doubleValue
                            self.pressure =  pressure * 10
                            self.onChanged(value: self.pressure);
                        }
                    }
            )
        }
    }
    
    //まずこれが呼ばれる
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_barometer", binaryMessenger: registrar.messenger())
        let stream = FlutterEventChannel(name: "pressureStream", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterBarometer()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stream.setStreamHandler(instance)
    }
    
    // EventChannel 初期化
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sinkOnChanged  = events
        listeningOnChanged = true
        return nil
    }
    
    // EventChannel 終了処理
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        listeningOnChanged = false
        return nil
    }
    
    // EventChannel 値を流す
    public func onChanged(value: Double) {
        if listeningOnChanged {
            if let sink = self.sinkOnChanged {
                sink(value)
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getCurrentPressure" {
            result(self.pressure)
        }
    }
}
