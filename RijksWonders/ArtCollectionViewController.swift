import UIKit
import RijksWondersModels

class ArtCollectionViewController: UIViewController {

    var model: ArtCollection!
    
    var busyIndicator: UIActivityIndicatorView!
    var artCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = try? ArtCollection(pageSize: Config.pageSize)
        
        assert(model != nil, "Could not initialize model")
        
        view.backgroundColor = .white
        
        let layout: UICollectionViewFlowLayout = .init()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 200)
        artCollection = .init(frame: view.frame, collectionViewLayout: layout)
        artCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Config.cellId)
        artCollection.backgroundColor = view.backgroundColor
        artCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artCollection)
        
        busyIndicator = .init()
        busyIndicator.style = .large
        busyIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(busyIndicator)
        
        NSLayoutConstraint.activate([
            artCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            artCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            artCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            artCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            busyIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            busyIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        model.onStartLoading = { [busyIndicator] in
            busyIndicator?.startAnimating()
        }
        
        model.onStopLoading = { [busyIndicator] in
            busyIndicator?.stopAnimating()
        }
        
        model.onReady = { [artCollection] in
            artCollection?.reloadData()
        }
        
        model.onUpdate = { [artCollection] in
            artCollection?.reloadSections(artCollection.)
        }
        
        model.onFailure = { _ in
            //
        }
    }
}
