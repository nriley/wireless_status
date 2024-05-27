//
//  main.swift
//  wireless_status
//
//  Created by Nicholas Riley on 5/26/2024.
//

// Based upon https://github.com/aegixx/bitbar-plugins/blob/master/Network/wifisignal.sh

import CoreWLAN

extension CWChannelBand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2.4 GHz"
        case .band5GHz: return "5 GHz"
        case .band6GHz: return "6 GHz"
        default: return "<unknown>"
        }
    }
}

extension CWChannelWidth: CustomStringConvertible {
    public var description: String {
        switch self {
        case .width20MHz: return "20 MHz"
        case .width40MHz: return "40 MHz"
        case .width80MHz: return "80 MHz"
        case .width160MHz: return "160 MHz"
        default: return "<unknown>"
        }
    }
}

extension CWInterfaceMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "No Network"
        case .station: return "Station"
        case .IBSS: return "IBSS Mode"
        case .hostAP: return "Personal Hotspot"
        @unknown default: return "<unknown>"
        }
    }
}

func rssiRating(_ rssi: Int) -> (String, String) {
    switch rssi {
    case -30 ..< 0: return ("Amazing", "forestgreen")
    case -50 ..< -30: return ("Excellent", "teal")
    case -60 ..< -50: return ("Good", "navy")
    case -70 ..< -60: return ("OK", "blueviolet")
    case -80 ..< -70: return ("Not Good", "olive")
    case -90 ..< -80: return ("Unusable", "red")
    default: return ("Unknown", "#ccc")
    }
}

func printWLANInfo() {
    let client = CWWiFiClient.shared()

    guard let interface = client.interface() else {
        print("Wi-Fi not found")
        return
    }

    guard interface.powerOn() else {
        print("Wi-Fi off")
        return
    }

    let interfaceMode = interface.interfaceMode()
    guard interfaceMode == CWInterfaceMode.station else {
        print(interfaceMode)
        return
    }

    let rssi = interface.rssiValue()
    let noise = interface.noiseMeasurement()
    let snr = rssi - noise
    let quality = min(snr * 2, 100)

    let (rating, color) = rssiRating(rssi)

    if let channel = interface.wlanChannel() {
        print("\(channel.channelNumber) (\(channel.channelBand), \(channel.channelWidth)) | color=\(color) font=SFMono-Bold size=12")
        print("---")
    }

    print("Signal: \(rssi) dBm (\(rating)) | color=black")
    print("Quality: \(quality)% (\(snr) dBm SNR) | color=black")
    print("---")
    print("Refresh | refresh=true")
}

printWLANInfo()
