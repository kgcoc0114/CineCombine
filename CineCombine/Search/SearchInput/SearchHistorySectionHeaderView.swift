//
//  SearchHistorySectionHeaderView.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation
import UIKit
import Combine

class SearchHistorySectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SearchHistorySectionHeaderView"

    private let titleLabel = UILabel()
    private let clearButton = UIButton()

    private let clearButtonTapSubject = PassthroughSubject<Void, Never>()
    var clearButtonTapPublisher: AnyPublisher<Void, Never> {
        clearButtonTapSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureContents() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(clearButton)

        titleLabel.font = .systemFont(ofSize: 22)
        titleLabel.text = "Recent searches"

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            clearButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            clearButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        ])
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 15)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.addTarget(self,
                              action: #selector(clearButtonDidPressed(_:)),
                              for: .touchUpInside)
    }

    @objc private func clearButtonDidPressed(_ sender: UIButton) {
        self.clearButtonTapSubject.send()
    }
}
