//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 01.06.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let imageFeed: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.likeInactive), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0xFFFFFF)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(imageFeed)
        imageFeed.addSubview(likeButton)
        imageFeed.addSubview(dateLabel)
        
        let padding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            imageFeed.topAnchor.constraint(equalTo: topAnchor, constant: padding / 4),
            imageFeed.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            imageFeed.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            imageFeed.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding / 4),
            
            likeButton.topAnchor.constraint(equalTo: imageFeed.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: imageFeed.trailingAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            
            dateLabel.leadingAnchor.constraint(equalTo: imageFeed.leadingAnchor, constant: padding / 2),
            dateLabel.bottomAnchor.constraint(equalTo: imageFeed.bottomAnchor, constant: -padding / 2),
            dateLabel.widthAnchor.constraint(equalToConstant: 152),
            dateLabel.heightAnchor.constraint(equalToConstant: 18),
            
        ])
    }
    
    public func setCell(photoName: String, indexPath: IndexPath) {
        imageFeed.image = UIImage(named: photoName)
        dateLabel.text = dateFormatter.string(from: Date())
        likeButton.setImage(UIImage(named: indexPath.row % 2 == 0 ? Constants.likeInactive : Constants.likeActive), for: .normal)
    }
}
