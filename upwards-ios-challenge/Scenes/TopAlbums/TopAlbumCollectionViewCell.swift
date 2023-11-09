//
//  TopAlbumCollectionViewCell.swift
//  upwards-ios-challenge
//
//  Created by Charles Prutting on 11/6/23.
//

import UIKit

class TopAlbumCollectionViewCell: UICollectionViewCell {
        
    let containerView = UIView()
    let stackView = UIStackView()
    let textStack = UIStackView()
    let albumArt = UIImageView()
    let albumLabel = UILabel()
    let artistLabel = UILabel()
    let recentlyReleasedLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        constrain()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        albumLabel.font = UIFont(name: "GillSans-SemiBold", size: 16)
        artistLabel.font = UIFont(name: "GillSans-LightItalic", size: 19)
        
        textStack.axis = .vertical
        textStack.distribution = .fillProportionally
        textStack.layoutMargins = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 6)
        textStack.isLayoutMarginsRelativeArrangement = true
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .white
    }
    
    private func constrain() {
        textStack.addArrangedSubview(albumLabel)
        textStack.addArrangedSubview(artistLabel)
        
        stackView.addArrangedSubview(albumArt)
        stackView.addArrangedSubview(textStack)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
 
        NSLayoutConstraint.activate([
            // Container View
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            // Stack View
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    private func showRecentlyReleasaed() {
        //Configure
        recentlyReleasedLabel.text = "  NEW  "
        recentlyReleasedLabel.font = UIFont(name: "GillSans-UltraBold", size: 16)
        recentlyReleasedLabel.textColor = .black
        recentlyReleasedLabel.backgroundColor = .white
        recentlyReleasedLabel.layer.cornerRadius = 5
        recentlyReleasedLabel.layer.masksToBounds = true
        recentlyReleasedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Constrain
        containerView.addSubview(recentlyReleasedLabel)
        NSLayoutConstraint.activate([
            recentlyReleasedLabel.topAnchor.constraint(equalTo: albumArt.topAnchor, constant: 10),
            recentlyReleasedLabel.trailingAnchor.constraint(equalTo: albumArt.trailingAnchor, constant: -8)
        ])
    } 
    private func removeRecentlyReleased() {
        //Remove label if need be for re-used cells
        recentlyReleasedLabel.text = ""
    }
    
    private func loadAlbumArt(artURL: String) {
        //Set default image while album art loads
        albumArt.image = UIImage(named: "emptyAlbum")
        //Load Album art images asynchronously
        let url = URL(string:artURL)
        DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url!) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.albumArt.image = UIImage(data: data)
                }
            }
        }
    }
    
    func setAlbumInfo(album: Album) {
        albumLabel.text = album.name
        artistLabel.text = album.artistName
        loadAlbumArt(artURL: album.artworkUrl100!)
        
        //Check if album was released in last week and display recently released label if so
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now)
        if oneMonthAgo! < album.releaseDate {
            showRecentlyReleasaed()
        } else {
            removeRecentlyReleased()
        }
        
        //Round corners and add drop shadow to cell
        shadowDecorate()
    }
    
}


// MARK: - UICollectionViewCell Custom Methods

extension UICollectionViewCell {
    func shadowDecorate() {
        let radius: CGFloat = 10
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
    
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}

