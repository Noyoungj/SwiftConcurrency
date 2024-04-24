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
    
    private let imageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
    }
    
    private func addSubviews() {
        self.view.addSubview(button)
        self.view.addSubview(imageView)
    }
    
    private func setLayouts() {
        imageView.snp.makeConstraints{
            $0.leading
                .trailing
                .top
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
        guard let url = URL(string: "https://reqres.in/api/users?page=2") else { return }
        
        Task {
            guard let imageURL = try? await self.requestImageURL(requestURL: url),
                  let url = URL(string: imageURL),
                  let data = try? Data(contentsOf: url) else { return }
            print("is clickAction MainThread?: \(Thread.isMainThread)")
            self.imageView.image = UIImage(data: data)
        }
    }
    
    func requestImageURL(requestURL: URL) async throws -> String {
        print("is requestImageURL MainThread?: \(Thread.isMainThread)")
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        return try JSONDecoder().decode(MyModel.self, from: data).data.first?.avatar ?? ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        
        addSubviews()
        setLayouts()
    }


}

struct MyModel: Codable {
    let page, perPage, total, totalPages: Int
    let data: [Datum]
    let support: Support

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }
}

struct Datum: Codable {
    let id: Int
    let email, firstName, lastName: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

struct Support: Codable {
    let url: String
    let text: String
}
