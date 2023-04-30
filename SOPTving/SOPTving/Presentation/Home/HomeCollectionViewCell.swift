//
//  HomeCollectionViewCell.swift
//  SOPTving
//
//  Created by 김민재 on 2023/04/28.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    private let dummy = Content.dummy()
    private let channelDummy = Channel.dummy()
    private var headerTexts: [String] = []

    // MARK: - UI Components

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
        $0.backgroundColor = .tvingBlack
    }

    @frozen
    enum Section: Int, CaseIterable {
        case liveChannel = 0
        case movieAndDrama
        case imageBanner
        case carousel

        var sectionInsetBottom: CGFloat {
            switch self {
            case .liveChannel:
                return 18
            case .movieAndDrama:
                return 49
            case .imageBanner, .carousel:
                return .zero
            }
        }
    }

    // MARK: - View Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initCellData(headerTexts: [String]) {
        self.headerTexts = headerTexts
    }
}

// MARK: - UI & Layout

extension HomeCollectionViewCell {
    private func setDelegate() {
        collectionView.dataSource = self
    }

    private func setStyle() {
        contentView.backgroundColor = .tvingBlack
        collectionView.do {
            $0.register(MovieDramaCollectionViewCell.self, forCellWithReuseIdentifier: MovieDramaCollectionViewCell.className)
            $0.register(PopularChannelCollectionViewCell.self, forCellWithReuseIdentifier: PopularChannelCollectionViewCell.className)
            $0.register(ImageBannerCollectionViewCell.self, forCellWithReuseIdentifier: ImageBannerCollectionViewCell.className)
            $0.register(MainSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainSectionHeaderView.className)
        }
    }

    private func setLayout() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }

            switch sectionType {
            case .movieAndDrama:
                return self.createMovieAndDramaSectionLayout(sectionType: sectionType)
            case .liveChannel:
                return self.createLiveChannelSectionLayout(sectionType: sectionType)
            case .imageBanner:
                return self.createImageBannerSectionLayout(sectionType: sectionType)
            case .carousel:
                return nil
            }
            //TODO: - layout
        }

        return layout
    }
}

// MARK: - Methods

extension HomeCollectionViewCell {

    private func createMovieAndDramaSectionLayout(sectionType: Section) -> NSCollectionLayoutSection {
        // item -> group -> section -> layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.3),
            heightDimension: .estimated(150)
        )

        let group = NSCollectionLayoutGroup
            .horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let sectionHeader = createSectionHeader()

        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 15, bottom: sectionType.sectionInsetBottom, trailing: 7)

        return section
    }

    private func createLiveChannelSectionLayout(sectionType: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 7)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.4),
            heightDimension: .estimated(140)
        )
        let group = NSCollectionLayoutGroup
            .horizontal(layoutSize: groupSize, subitems: [item])


        let sectionHeader = createSectionHeader()
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 12, bottom: sectionType.sectionInsetBottom, trailing: 5)

        return section
    }

    private func createImageBannerSectionLayout(sectionType: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let gropSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(58)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: gropSize, repeatingSubitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    private func createCarouselSectionLayout(sectionType: Section) {

    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(30)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading)
        return sectionHeader
    }

}

// MARK: - UICollectionViewDelegate
// MARK: - UICollectionViewDataSource

extension HomeCollectionViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MainSectionHeaderView.className, for: indexPath) as? MainSectionHeaderView else { return UICollectionReusableView() }
        header.configHeaderView(text: headerTexts[indexPath.section])
        return header
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        if sectionType == .imageBanner {
            return 1
        }
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularChannelCollectionViewCell.className, for: indexPath) as? PopularChannelCollectionViewCell else { return UICollectionViewCell() }

            cell.configureCell(rank: indexPath.item + 1, channel: channelDummy[indexPath.item])

            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieDramaCollectionViewCell.className, for: indexPath) as? MovieDramaCollectionViewCell else { return UICollectionViewCell() }

            cell.configureCell(content: dummy[indexPath.item])
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageBannerCollectionViewCell.className, for: indexPath) as? ImageBannerCollectionViewCell else { return UICollectionViewCell() }
            return cell
        default:
            return UICollectionViewCell()
        }

    }
}
