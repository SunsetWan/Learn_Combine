//
//  LearnUICollectionViewCompositionalLayoutViewController.swift
//  Learn_Combine_Example
//
//  Created by Sunset Wan on 10/1/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Combine

protocol EmptyHouseCellDelegate: AnyObject {
    func didPressDeleteButton()
}

struct EmptyHouseDetail: Hashable {

    let name: String

    init(name: String) {
        self.name = name
    }
}

class EmptyHouseCell: UICollectionViewCell {
    static let reuseIdentifer = "empty-house-cell-reuse-identifier"
    static let leadingSpace: CGFloat = 39.5
    static let trashBinWidth: CGFloat = 56

    private let titleLabel = UILabel()
    private let trashBinButton = UIButton()
    private let grayLine = UIView()
    let hStackView = UIStackView()

    weak var delegate: EmptyHouseCellDelegate?

    @Published var houseName: String?
    private var houseNameSubscriber: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        houseNameSubscriber = $houseName.assign(to: \.text, on: titleLabel)
        titleLabel.text = "空房屋 1"
        trashBinButton.setImage(UIImage(named: "Delete"), for: .normal)

        // titleLabel: font, textColor
        hStackView.axis = .horizontal
        hStackView.addArrangedSubview(titleLabel)
        hStackView.addArrangedSubview(trashBinButton)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hStackView)

//        hStackView.layer.borderWidth = 1
//        hStackView.layer.borderColor = UIColor.blue.cgColor

        grayLine.backgroundColor = .lightGray
        grayLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(grayLine)

        NSLayoutConstraint.activate([
            // Horizonal
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: EmptyHouseCell.leadingSpace),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -EmptyHouseCell.leadingSpace),
            trashBinButton.widthAnchor.constraint(equalToConstant: EmptyHouseCell.trashBinWidth),
            grayLine.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor),
            grayLine.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor),

            // Vertical
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: grayLine.topAnchor),
            grayLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            grayLine.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}

class EmptyHouseListPage: UIView {
    class HeaderView: UIView {
        let titleLabel = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func commonInit() {
            titleLabel.text = "空房屋（4）"
            titleLabel.font = .systemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)

            NSLayoutConstraint.activate([
                // Horizonal
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

                // Vertical
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            ])
        }

    }

    enum Section {
        case main
    }

    private let headerView = HeaderView()
    private(set) var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, EmptyHouseDetail>!

    private let dismissButton = UIButton()
    private let buttonLayoutGuide = UILayoutGuide()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .white
        configureCollectionView()
        configureHeaderView()
        configureDataSource()
        configureDismissButton()
        initLayout()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())

        collectionView.register(EmptyHouseCell.self, forCellWithReuseIdentifier: EmptyHouseCell.reuseIdentifer)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
    }

    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, EmptyHouseDetail>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, emptyHouseDetail) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmptyHouseCell.reuseIdentifer,
                    for: indexPath) as? EmptyHouseCell else {
//                    return UICollectionViewCell()
                    fatalError("123")
                }
                cell.houseName = emptyHouseDetail.name
                return cell
            })

        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func configureDismissButton() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("收起", for: .normal)
        dismissButton.setTitleColor(.black, for: .normal)
        addSubview(dismissButton)
        addLayoutGuide(buttonLayoutGuide)
    }

    private func initLayout() {
        NSLayoutConstraint.activate([
            // horizonal
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            dismissButton.leadingAnchor.constraint(equalTo: buttonLayoutGuide.leadingAnchor, constant: 40),
            dismissButton.trailingAnchor.constraint(equalTo: buttonLayoutGuide.trailingAnchor, constant: -40),

            // Vertical
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 48),
            headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            buttonLayoutGuide.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 26),
            buttonLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            buttonLayoutGuide.heightAnchor.constraint(equalToConstant: 106),
            dismissButton.topAnchor.constraint(equalTo: buttonLayoutGuide.topAnchor, constant: 16),
            dismissButton.bottomAnchor.constraint(equalTo: buttonLayoutGuide.bottomAnchor, constant: -34),
        ])
    }

    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, EmptyHouseDetail> {
      var snapshot = NSDiffableDataSourceSnapshot<Section, EmptyHouseDetail>()
      snapshot.appendSections([Section.main])
      let items = itemsForHouse()
      snapshot.appendItems(items)
      return snapshot
    }

    private func itemsForHouse() -> [EmptyHouseDetail] {
        [
            EmptyHouseDetail(name: "空房屋 1"),
            EmptyHouseDetail(name: "空房屋 2"),
            EmptyHouseDetail(name: "空房屋 3"),
            EmptyHouseDetail(name: "空房屋 4"),
        ]
    }

    private func generateLayout() -> UICollectionViewLayout {
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ))

        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(48))

        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: groupSize,
          subitem: mainItem,
          count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// 🔗: https://www.kodeco.com/5436806-modern-collection-views-with-compositional-layouts
class LearnUICollectionViewCompositionalLayoutViewController: UIViewController {

    class HeaderView: UIView {
        let titleLabel = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func commonInit() {
            titleLabel.text = "空房屋（4）"
            titleLabel.font = .systemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)

            NSLayoutConstraint.activate([
                // Horizonal
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

                // Vertical
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            ])
        }

    }

    enum Section {
        case main
    }

    private let headerView = HeaderView()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, EmptyHouseDetail>!

    private let dismissButton = UIButton()
    private let buttonLayoutGuide = UILayoutGuide()

    private let page: EmptyHouseListPage = EmptyHouseListPage()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        configureCollectionView()
//        configureHeaderView()
//        configureDataSource()
//        configureDismissButton()
//        initLayout()
        page.collectionView.delegate = self

        page.translatesAutoresizingMaskIntoConstraints = false
        page.backgroundColor = .lightGray
        view.addSubview(page)

        NSLayoutConstraint.activate([
            // Horizonal
            page.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            page.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Vertical
            page.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            page.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.delegate = self
        collectionView.register(EmptyHouseCell.self, forCellWithReuseIdentifier: EmptyHouseCell.reuseIdentifer)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }

    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, EmptyHouseDetail>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, emptyHouseDetail) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmptyHouseCell.reuseIdentifer,
                    for: indexPath) as? EmptyHouseCell else {
//                    return UICollectionViewCell()
                    fatalError("123")
                }
                cell.houseName = emptyHouseDetail.name
                return cell
            })

        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func configureDismissButton() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("收起", for: .normal)
        dismissButton.setTitleColor(.black, for: .normal)
        view.addSubview(dismissButton)
        view.addLayoutGuide(buttonLayoutGuide)
    }

    private func initLayout() {
        NSLayoutConstraint.activate([
            // horizonal
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dismissButton.leadingAnchor.constraint(equalTo: buttonLayoutGuide.leadingAnchor, constant: 40),
            dismissButton.trailingAnchor.constraint(equalTo: buttonLayoutGuide.trailingAnchor, constant: -40),

            // Vertical
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            buttonLayoutGuide.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 26),
            buttonLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonLayoutGuide.heightAnchor.constraint(equalToConstant: 106),
            dismissButton.topAnchor.constraint(equalTo: buttonLayoutGuide.topAnchor, constant: 16),
            dismissButton.bottomAnchor.constraint(equalTo: buttonLayoutGuide.bottomAnchor, constant: -34),
        ])
    }

    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, EmptyHouseDetail> {
      var snapshot = NSDiffableDataSourceSnapshot<Section, EmptyHouseDetail>()
      snapshot.appendSections([Section.main])
      let items = itemsForHouse()
      snapshot.appendItems(items)
      return snapshot
    }

    private func itemsForHouse() -> [EmptyHouseDetail] {
        [
            EmptyHouseDetail(name: "空房屋 1"),
            EmptyHouseDetail(name: "空房屋 2"),
            EmptyHouseDetail(name: "空房屋 3"),
            EmptyHouseDetail(name: "空房屋 4"),
        ]
    }

    private func generateLayout() -> UICollectionViewLayout {
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ))

        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(48))

        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: groupSize,
          subitem: mainItem,
          count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension LearnUICollectionViewCompositionalLayoutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
