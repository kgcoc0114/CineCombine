//
//  ErrorView.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/12/5.
//

import UIKit

final class ErrorView: UIView {
    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let errorActionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private var action: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commitInit()
    }

    private func commitInit() {
        self.backgroundColor = .systemBackground
        self.addSubview(stackView)
        [errorTitleLabel,
         errorMessageLabel,
         errorActionButton]
            .forEach {
                stackView.addArrangedSubview($0)
            }
        errorActionButton.addTarget(self, action: #selector(didTapErrorActionButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            errorActionButton.widthAnchor.constraint(equalToConstant: 50),
            errorActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc
    private func didTapErrorActionButton() {
        action?()
    }

    func configure(title: String? = nil,
                   message: String? = nil,
                   action: (() -> Void)? = nil) {
        errorTitleLabel.text = title
        errorMessageLabel.text = message
        self.action = action

        errorTitleLabel.isHidden = title == nil
        errorMessageLabel.isHidden = message == nil
        errorActionButton.isHidden = action == nil

    }
}
