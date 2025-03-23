//
//  SearchResultListCollectionViewCell.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/22.
//

import UIKit

protocol SearchResultCellViewModelProtocol: CellViewModelProtocol {
    var uniqueId: Int? { get }
    var postURL: String? { get }
    var title: String? { get }
    var subTitle: String? { get }
    var overview: String? { get }
}

class SearchResultListCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchResultCardCollectionViewCell"

    // MARK: - UI Constants
    private enum Constants {
        static let containerInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        static let posterAspectRatio: CGFloat = 3 / 4
        static let cornerRadius: CGFloat = 10
        static let stackViewSpacing: CGFloat = 8
        static let contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let overviewNumberOfLines = 8

        enum Font {
            static let title = UIFont.systemFont(ofSize: 20, weight: .semibold)
            static let subtitle = UIFont.systemFont(ofSize: 15)
            static let overview = UIFont.systemFont(ofSize: 13)
        }
    }

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.subtitle
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Font.overview
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = Constants.overviewNumberOfLines
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
    }
    
    private func initLayout() {
        setupContainerView()
        setupPosterImageView()
        setupRightStackView()
    }
    
    // MARK: - UI Configuration
    private func setupContainerView() {
        self.contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.containerInsets.top),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.containerInsets.left),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.containerInsets.right),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.containerInsets.bottom)
        ])
    }
    
    private func setupPosterImageView() {
        self.containerView.addSubview(posterImageView)
        let posterHeight = ceil(UIScreen.main.bounds.width * 0.3)
        NSLayoutConstraint.activate([
            posterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInsets.left),
            posterImageView.heightAnchor.constraint(equalToConstant: posterHeight),
            posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: Constants.posterAspectRatio),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: posterHeight + 20)
        ])
    }
    
    private func setupRightStackView() {
        self.containerView.addSubview(rightStackView)
        NSLayoutConstraint.activate([
            rightStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.contentInsets.top),
            rightStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: Constants.contentInsets.left),
            rightStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInsets.right)
        ])
        
        [titleLabel, subTitleLabel, overviewLabel].forEach { view in
            rightStackView.addArrangedSubview(view)
        }

        let bottomConstraint = containerView.bottomAnchor.constraint(equalTo: rightStackView.bottomAnchor, constant:  Constants.contentInsets.bottom)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
    
    func configure(item: SearchResultCellViewModelProtocol, indexPath: IndexPath) {
        posterImageView.kfSetImage(url: URL(string: item.postURL ?? ""))
        titleLabel.text = item.title
        titleLabel.isHidden = item.title == nil
        subTitleLabel.text = item.subTitle
        subTitleLabel.isHidden = item.subTitle == nil
        overviewLabel.text = item.overview
        overviewLabel.isHidden = item.overview == nil
    }
}
