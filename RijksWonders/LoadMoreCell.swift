import UIKit

final class LoadMoreCell: UICollectionViewCell {
    
    weak var loadMoreButton: UIButton?
    var onTap: () -> Void = {}
    
    override init(frame: CGRect) {
        
        let loadMoreButton = UIButton(configuration: .plain())
        loadMoreButton.setTitle("LOAD MORE", for: .normal)
        loadMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.loadMoreButton = loadMoreButton
        
        super.init(frame: frame)
        
        contentView.addSubview(loadMoreButton)
        
        NSLayoutConstraint.activate([
            loadMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadMoreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadMoreButton.widthAnchor.constraint(equalToConstant: 200),
            loadMoreButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        loadMoreButton.addTarget(self, action: #selector(onTapHandler), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func onTapHandler() {
        self.onTap()
    }
}
