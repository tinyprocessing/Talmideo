import UIKit

protocol BaseViewControllerDelegate: AnyObject {
    func willRouteTo(_ routeType: RouteType)
}

class BaseViewController: UIViewController {
    weak var delegate: BaseViewControllerDelegate?

    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue
        return activityIndicator
    }()

    var opaqueOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray.withAlphaComponent(0.2)
        return view
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        view.addSubview(opaqueOverlay)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            opaqueOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            opaqueOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            opaqueOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            opaqueOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        opaqueOverlay.isHidden = true
    }

    func startLoading(withOverlay: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if withOverlay {
                self.view.bringSubviewToFront(opaqueOverlay)
                self.opaqueOverlay.isHidden = false
            }
            self.view.bringSubviewToFront(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }

    func endLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.view.sendSubviewToBack(self.opaqueOverlay)
            self.opaqueOverlay.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func route(to routeType: RouteType) {
        delegate?.willRouteTo(routeType)
    }
}
