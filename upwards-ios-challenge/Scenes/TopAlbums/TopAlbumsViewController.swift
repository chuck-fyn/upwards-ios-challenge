//
//  TopAlbumsViewController.swift
//  upwards-ios-challenge
//
//  Created by Alex Livenson on 9/13/21.
//

import UIKit

final class TopAlbumsViewController: UIViewController {
    
    private let iTunesAPI: ITunesAPI
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var albumsListOriginalSorting = [Album]()
    private var albums = [Album]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(iTunesAPI: ITunesAPI) {
        self.iTunesAPI = iTunesAPI
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        constrain()
        loadData()
    }
    
    private func configure() {
        //Configure Nav Bar
        navigationItem.title = "TOP 100 ALBUMS"
        let menuHandler: UIActionHandler = { action in
            if action.title == "Chart Ranking" {
                self.albums = self.albumsListOriginalSorting
            } else if action.title == "Release Date"{
                self.albums.sort(by: {$0.releaseDate > $1.releaseDate})
            } else if action.title == "Album Title"{
                self.albums.sort(by: {$0.name < $1.name})
            } else if action.title == "Artist Name"{
                self.albums.sort(by: {$0.artistName < $1.artistName})
            }
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Chart Ranking", comment: "test test"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Release Date", comment: ""), handler: menuHandler),
            UIAction(title: NSLocalizedString("Album Title", comment: ""), handler: menuHandler),
            UIAction(title: NSLocalizedString("Artist Name", comment: ""), handler: menuHandler),
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "line.3.horizontal.decrease"), primaryAction: nil, menu: barButtonMenu)
        
        //Configure Collection View and Flow Layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .gray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TopAlbumCollectionViewCell.self, forCellWithReuseIdentifier: TopAlbumCollectionViewCell.description())
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        collectionViewFlowLayout.minimumLineSpacing = 10
    }
    
    private func constrain() {
        //Constrain Collection View
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func loadData() {
        iTunesAPI.getTopAlbums(limit: 100) { [weak self] res in
            switch res {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.albums = data.feed.results
                    self?.albumsListOriginalSorting = self!.albums
                }
            case .failure(let err):
                debugPrint(err)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension TopAlbumsViewController: UICollectionViewDataSource {
    
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let album = albums[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopAlbumCollectionViewCell.description(), for: indexPath) as! TopAlbumCollectionViewCell
        
        cell.setAlbumInfo(album: album)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TopAlbumsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint(albums[indexPath.row])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TopAlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((UIScreen.main.bounds.width - 30) / 2)
        let height = width * (4/3)
        return CGSize(width: width, height: height)
    }
}

