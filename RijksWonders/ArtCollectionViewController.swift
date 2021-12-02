import UIKit
import RijksWondersViewModels

class ArtCollectionViewController: UIViewController {

    var model: ArtCollectionScreen!
    
    var artCollection: UICollectionView!
    var loadingOverlay: UIView!
    var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = try? ArtCollectionScreen()
        
        assert(model != nil, "Could not initialize model")
        
        view.backgroundColor = .white
        
        let layout: UICollectionViewFlowLayout = .init()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 200)
        artCollection = .init(frame: view.frame, collectionViewLayout: layout)
        artCollection.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: ArtCollectionScreen.cellId
        )
        artCollection.backgroundColor = view.backgroundColor
        artCollection.translatesAutoresizingMaskIntoConstraints = false
        artCollection.isHidden = true
        view.addSubview(artCollection)
        
        loadingOverlay = UIView()
        loadingOverlay.backgroundColor = .darkGray
        loadingOverlay.alpha = 0.0
        loadingOverlay.isHidden = true
        loadingOverlay.isUserInteractionEnabled = false
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingOverlay)
        
        loadingIndicator = .init()
        loadingIndicator.style = .large
        loadingIndicator.tintColor = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            artCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            artCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            artCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            artCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
        
        model.onStartLoading = { [loadingOverlay, loadingIndicator] in
            loadingOverlay?.alpha = 0
            loadingOverlay?.isHidden = false
            UIView.animate(withDuration: Config.animationDuration) {
                loadingOverlay?.alpha = 0.5
                loadingIndicator?.startAnimating()
            }
        }
        
        model.onStopLoading = { [loadingOverlay, loadingIndicator] in
            UIView.animate(withDuration: Config.animationDuration) {
                loadingOverlay?.alpha = 0
                loadingIndicator?.stopAnimating()
            } completion: {
                if $0 {
                    loadingOverlay?.isHidden = true
                }
            }
        }
        
        model.onReady = { [artCollection] in
            artCollection?.alpha = 0
            artCollection?.isHidden = false
            UIView.animate(withDuration: Config.animationDuration) {
                artCollection?.alpha = 1
                artCollection?.reloadData()
            }
        }
        
        model.onUpdate = { [artCollection] index in
            UIView.animate(withDuration: Config.animationDuration) {
                artCollection?.reloadSections(.init(integer: index))
            }
        }
        
        model.onFailure = { [unowned self] in
            let alert = UIAlertController(
                title: $0.title,
                message: $0.message,
                preferredStyle: .alert
                )
            
            self.present(alert, animated: true)
        }
        
        model.fetch()
    }
}
