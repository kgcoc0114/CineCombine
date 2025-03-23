//
//  SearchResultCardCollectionViewCell.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/11/14.
//

import UIKit

class SearchResultCardCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchResultCardCollectionViewCell"

    private enum Constants {
        static let containerInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
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
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        return imageView
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(posterImageView)
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.contentInsets.top),
            posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.contentInsets.left),
            posterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.contentInsets.left),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.contentInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.contentInsets.top),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.contentInsets.bottom)
        ])
    }
    
    func configure(item: SearchResultCellViewModelProtocol, indexPath: IndexPath) {
        posterImageView.kfSetImage(url: URL(string: item.postURL ?? ""))
        titleLabel.text = item.title
        titleLabel.isHidden = item.title == nil
        subTitleLabel.text = item.subTitle
        subTitleLabel.isHidden = item.subTitle == nil
    }
}
