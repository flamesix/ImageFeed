//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 01.06.2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate? 
    
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
        button.accessibilityIdentifier = "LikeButton"
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
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    static func clean() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.backgroundCleanExpiredDiskCache()
        cache.cleanExpiredMemoryCache()
        cache.clearCache()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
   override func prepareForReuse() {
        super.prepareForReuse()
        imageFeed.kf.cancelDownloadTask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: Constants.likeActive) : UIImage(named: Constants.likeInactive)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(imageFeed)
        contentView.addSubview(likeButton)
        imageFeed.addSubview(dateLabel)
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
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
    
    public func setCell(photo: Photo) {
        let url = URL(string: photo.thumbImageURL)
        imageFeed.kf.indicatorType = .activity
        imageFeed.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder")) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageFeed.image = image.image
            case .failure(let error):
                print("Function: \(#function), line \(#line) Failed to Download Image \(error.localizedDescription)")
                self?.imageFeed.image = UIImage(named: "ImagePlaceholder")
            }
        }
        dateLabel.text = ImagesListCell.dateFormatter.string(from: photo.createdAt ?? Date())
        setIsLiked(isLiked: photo.isLiked)
    }
}
