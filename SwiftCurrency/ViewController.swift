//
//  ViewController.swift
//  SwiftCurrency
//
//  Created by 노영재(Youngjae No)_인턴 on 4/24/24.
//

import UIKit
import Then
import SnapKit

class ViewController: UIViewController {
    private let button = UIButton().then{
        $0.setTitle("이미지 요청", for: .normal)
        $0.backgroundColor = .blue
    }
    
    private let label = UILabel().then{
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private func addSubviews() {
        self.view.addSubview(button)
        self.view.addSubview(label)
    }
    
    private func setLayouts() {
        label.snp.makeConstraints{
            $0.leading
                .trailing
                .equalTo(view.safeAreaLayoutGuide)
            $0.bottom
                .equalTo(view.safeAreaLayoutGuide.snp.centerY)
        }
        button.snp.makeConstraints{
            $0.leading
                .equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.trailing
                .bottom
                .equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height
                .equalTo(70)
        }
    }
    
    @objc
    private func clickAction(_ sender: UIButton) {
        guard let url = URL(string: "https://auth.cryptokonai.com/realms/cryptokona/protocol/openid-connect/token") else { return }
        guard let ethurl = URL(string: "https://gateway.cryptokonai.com/eth/getPrice") else { return }

        Task {
            guard let token = try? await self.requestAccessURL(requestURL: url) else { return }
            print("is clickAction MainThread?: \(Thread.isMainThread)")
            guard let price = try? await self.requestGetETHURL(requestURL: ethurl, accessToken: token) else { return }
            self.label.text = String(price)
        }
    }
    func requestGetETHURL(requestURL: URL, accessToken: String) async throws -> Float {
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GetETHModel.self, from: data).data?.price ?? 0
    }
    
    func requestAccessURL(requestURL: URL) async throws -> String {
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters : [String: String] = ["client_id": "cryptokona_api",
                                          "client_secret": "LyiPUL0NKyTPuocOZXOLdkvTjlHBdDH0",
                                          "scope": "openid",
                                          "grant_type": "client_credentials"]
        // 파라미터를 URLQueryItem으로 변환
        let queryItems = parameters.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }

        // URLComponents를 사용하여 쿼리 스트링으로 변환
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems

        // URLRequest의 httpBody에 설정
        request.httpBody = urlComponents.query?.data(using: .utf8)
        
        print("is requestImageURL MainThread?: \(Thread.isMainThread)")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let responseData = String(data: data, encoding: .utf8) {
            print("Server error message:", responseData)
        }
        return try JSONDecoder().decode(AccessTokenModel.self, from: data).access_token ?? ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        
        addSubviews()
        setLayouts()
    }


}

struct AccessTokenModel: Codable {
    let access_token: String?
}

struct GetETHModel: Codable {
    let data: EthModel?
}

struct EthModel: Codable {
    let price: Float?
}

