import UIKit
import Kingfisher
import RijksWondersViewModels

class ArtCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {

    var model: ArtCollectionScreen!
    
    var artCollection: UICollectionView!
    var loadingOverlay: UIView!
    var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = try? ArtCollectionScreen()
        
        assert(model != nil, "Could not initialize model")
        
        title = "Collection"
        view.backgroundColor = .white
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 10 * 2
        let cellHeight = 200.0
        
        let layout: UICollectionViewFlowLayout = .init()
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        artCollection = .init(frame: view.frame, collectionViewLayout: layout)
        artCollection.register(
            ArtObjectCell.self,
            forCellWithReuseIdentifier: ArtCollectionScreen.cellId
        )
        artCollection.register(
            LoadMoreCell.self,
            forCellWithReuseIdentifier: ArtCollectionScreen.loadMoreCellId
        )
        artCollection.register(
            ArtObjectHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ArtCollectionScreen.headerId
        )
        artCollection.backgroundColor = view.backgroundColor
        artCollection.translatesAutoresizingMaskIntoConstraints = false
        artCollection.isHidden = true
        artCollection.dataSource = self
        artCollection.delegate = self
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
        view.addSubview(loadingIndicator)
        
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
                artCollection?.reloadData()
            }
        }
        
        model.onFailure = { [unowned self] in
            let alert = UIAlertController(
                title: $0.title,
                message: $0.message,
                preferredStyle: .alert
                )
            
            alert.addAction(
                .init(
                    title: "Dismiss",
                    style: .default,
                    handler: { [unowned self] _ in self.dismiss(animated: true) })
            )
            
            self.present(alert, animated: true)
        }
        
        model.fetch()
    }
}

// MARK: - UICollectionView support

extension ArtCollectionViewController {
    
    func numberOfSections(in _: UICollectionView) -> Int {
        model.numberOfPreloadedSections
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection sectionIndex: Int) -> Int {
        
        let addExtraCell = (model.numberOfPreloadedSections - 1) == sectionIndex // extra cell for "load more"?
        return model.preloadedSection(for: sectionIndex).items.count + (addExtraCell ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        .init(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {

            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ArtCollectionScreen.headerId,
                    for: indexPath
                )

            default:
                fatalError("Unexpected element kind")
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let isLastSection = indexPath.section == (model.numberOfPreloadedSections - 1)
        let section = model.preloadedSection(for: indexPath.section)
        let isLastCell = indexPath.item == section.items.count // beyond last item
        
        if isLastSection && isLastCell {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: ArtCollectionScreen.loadMoreCellId,
                for: indexPath
            )
        } else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: ArtCollectionScreen.cellId,
                for: indexPath
            )
        }
    }
    
    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? ArtObjectCell {
            
            let item = model.preloadedSection(for: indexPath.section).items[indexPath.item]
            
            cell.imageView?.kf.setImage(with: item.headerImage.url)
            cell.titleLabel?.text = item.title
        }
        
        if let cell = cell as? LoadMoreCell {
            
            cell.onTap = { [weak model] in model?.fetchNext() }
        }
    }
    
    func collectionView(_: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        guard let header = view as? ArtObjectHeaderView else { return }
        
        let section = model.preloadedSection(for: indexPath.section)
        
        header.titleLabel?.text = section.title
    }
    
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = model.preloadedItem(for: indexPath.item, section: indexPath.section) else {return }
        
        let detailsScreen = ArtDetailsViewController()
        detailsScreen.configure(with: item)
        navigationController?.pushViewController(detailsScreen, animated: true)
    }
}
