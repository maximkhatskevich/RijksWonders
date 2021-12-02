import UIKit
import Kingfisher
import RijksWondersViewModels

class ArtDetailsViewController: UIViewController {
    
    var model: ArtCollectionScreen.Item!
    
    weak var imageView: UIImageView?
    weak var titleLabel: UILabel?
    weak var subtitleLabel: UILabel?
    
    func configure(with model: ArtCollectionScreen.Item) {
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(model != nil, "Could not initialize model")
        
        title = model.title
        view.backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView = imageView
        view.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel = titleLabel
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel = subtitleLabel
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        imageView.kf.setImage(with: model.webImage.url)
        titleLabel.text = model.longTitle
        subtitleLabel.text = model.principalOrFirstMaker
    }
}
