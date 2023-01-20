//
//  GithubUserSearchViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 9/1/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Combine

enum APIFailureCondition: Error {
    case invalidServerResponse
}

struct GithubAPIUser: Decodable {
    // A very *small* subset of the content available about
    //  a github API user for example:
    // https://api.github.com/users/heckj
    let login: String
    let public_repos: Int
    let avatar_url: String
}

class GithubUserSearchView: UIView {
    let userIDTextField = UITextField(frame: .zero)
    let avatarImageView = UIImageView()
    let hStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        hStackView.axis = .horizontal
        hStackView.spacing = 5
        hStackView.addArrangedSubview(userIDTextField)
        hStackView.addArrangedSubview(avatarImageView)

        hStackView.translatesAutoresizingMaskIntoConstraints = false
        hStackView.layer.borderColor = UIColor.lightGray.cgColor
        hStackView.layer.borderWidth = 1

        addSubview(hStackView)
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStackView.heightAnchor.constraint(equalToConstant: 128),

            avatarImageView.widthAnchor.constraint(equalToConstant: 128),
        ])

        userIDTextField.placeholder = "Please enter userID"
        avatarImageView.image = UIImage(named: "image_place_holder")
    }
}

class GithubUserSearchViewController: UIViewController {
    let page = GithubUserSearchView()
    let activityIndicator = UIActivityIndicatorView()

    var userNameSub: AnyCancellable?
    var avatarViewSubscriber: AnyCancellable?
    var apiNetworkActivitySubscriber: AnyCancellable?
    @Published var userName: String = ""
    @Published var githubUserData = [GithubAPIUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureActivityIndicator()
        initViews()
        initPubSub()

        page.userIDTextField.addTarget(self, action: #selector(githubIDChanged), for: .editingChanged)
    }

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.color = .blue
    }

    private func initViews() {
        page.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(page)

        NSLayoutConstraint.activate([
            page.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            page.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            page.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: page.avatarImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: page.avatarImageView.centerYAnchor),
        ])
    }

    // executes tasks serially.
    var myBackgroundQueue: DispatchQueue = .init(label: "myBackgroundQueue", qos: .background)

    private func initPubSub() {

        apiNetworkActivitySubscriber = GithubAPI.networkHUDPub
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { doingSomethingNow in
                if doingSomethingNow {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            })

        let usernamePub = $userName
            .throttle(for: 5, scheduler: myBackgroundQueue, latest: true)
            .removeDuplicates()
            .print("userNameSub: ")
            .map { username -> AnyPublisher<[GithubAPIUser], Never> in
                return GithubAPI.retrieveGithubUser(username: username)
            }
            .switchToLatest()
            .receive(on: RunLoop.main)
            .assign(to: \.githubUserData, on: self)

        avatarViewSubscriber = $githubUserData
            .print("github user data: ")
            .map { userData -> AnyPublisher<UIImage, Never> in
                guard let firstUser = userData.first else {
                    return Just(UIImage()).eraseToAnyPublisher()
                }

                return URLSession.shared.dataTaskPublisher(for: URL(string: firstUser.avatar_url)!)
                    .handleEvents(receiveSubscription: { _ in
                        DispatchQueue.main.async {
                            self.activityIndicator.startAnimating()
                        }
                    }, receiveCompletion: { _ in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    }, receiveCancel: {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    })
                    .receive(on: self.myBackgroundQueue)


            }
            .sink {_ in}
    }

    @objc
    func githubIDChanged() {
        userName = page.userIDTextField.text ?? ""
//        print("Set username to \(userName)")
    }
}

enum GithubAPI {
    static let networkHUDPub = PassthroughSubject<Bool, Never>()

    static func retrieveGithubUser(username: String) -> AnyPublisher<[GithubAPIUser], Never> {
        if username.count < 3 {
            let a = Just([GithubAPIUser]()).eraseToAnyPublisher()
            return a
        }

        let assembledURL = String("https://api.github.com/users/\(username)")
        let publisher = URLSession.shared.dataTaskPublisher(for: URL(string: assembledURL)!)
            .handleEvents(receiveSubscription: { _ in
                networkHUDPub.send(true)
            }, receiveCompletion: {_ in
                networkHUDPub.send(false)
            }, receiveCancel: {
                networkHUDPub.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw APIFailureCondition.invalidServerResponse
                }
                return data
            }
            .decode(type: GithubAPIUser.self, decoder: JSONDecoder())
            .map {
                [$0]
            }
            .catch { error in
                return Just([])
            }
            .eraseToAnyPublisher()

        return publisher
    }
}
