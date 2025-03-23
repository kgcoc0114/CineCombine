//
//  SearchInputItemTableViewCell.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import UIKit

protocol SearchLogic {
    var keyword: String { get }
    var isSearchOption: Bool { get }
    var cellType: SearchType { get }
    var searchResultViewModel: SearchResultViewModel? { get }
    func updateKeyword(with keyword: String)
}

extension SearchLogic {
    
    func calculateTitle(displayName: String?) -> String? {
        keyword.isEmpty == false && isSearchOption
        ? cellType.searchOptionTitle(keyword: keyword)
        : displayName
    }

    func createSearchResultViewModel() -> SearchResultViewModel {
        SearchResultViewModel(searchType: cellType,
                              keywordText: keyword,
                              isFromSearchOption: isSearchOption)
    }
}

protocol SearchInputItemCellViewModelProtocol: CellViewModelProtocol {
    var iconImage: UIImage { get }
    var title: String? { get }
    var subTitle: String? { get }
    var imageURL: String? { get }
}

class SearchInputItemTableViewCell: UITableViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.selectionStyle = .none

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),
            avatarImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            avatarImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),

            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }

    func configure(item: SearchInputItemCellViewModelProtocol) {
        titleLabel.text = item.title ?? ""

        if let subTitle = item.subTitle {
            subTitleLabel.text = subTitle
            subTitleLabel.isHidden = false
        } else {
            subTitleLabel.isHidden = true
        }
        
        avatarImageView.kfSetImage(url: URL(string: item.imageURL ?? ""),
                                   placeholder: item.iconImage)
    }
}

class SearchInputItemCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchInputItemCollectionViewCell"

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
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

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),
            avatarImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            avatarImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),

            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }

    func configure(item: SearchInputItemCellViewModelProtocol) {
        titleLabel.text = item.title ?? ""

        if let subTitle = item.subTitle {
            subTitleLabel.text = subTitle
            subTitleLabel.isHidden = false
        } else {
            subTitleLabel.isHidden = true
        }

        avatarImageView.kfSetImage(url: URL(string: item.imageURL ?? ""),
                                   placeholder: item.iconImage)
    }
}
