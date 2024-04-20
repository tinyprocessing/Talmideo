import Combine
import UIKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func close()
}

final class OnboardingViewController: BaseViewController {
    private var pages: [UIViewController] = []
    public weak var onboardingDelegate: OnboardingViewControllerDelegate?

    private lazy var pageViewController: UIPageViewController = {
        let view = UIPageViewController(transitionStyle: .scroll,
                                        navigationOrientation: .horizontal,
                                        options: nil)
        view.delegate = self
        view.dataSource = self
        view.view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.currentPage = 0
        view.pageIndicatorTintColor = .secondaryLabel.withAlphaComponent(0.05)
        view.currentPageIndicatorTintColor = .black
        return view
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(.localized(.next), for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.customFont(.robotoSlabRegular, size: 18)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.setTitleColor(.black, for: .highlighted)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        view.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: nil)
        visualEffectView.frame = view.bounds
        visualEffectView.layer.opacity = 0

        view.addSubview(visualEffectView)
        view.layer.opacity = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.3) {
                visualEffectView.effect = blurEffect
                visualEffectView.layer.opacity = 1.0
                self.view.layer.opacity = 1.0
            }
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.addSubview(pageControl)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nextButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Config.buttonNextOffest
            ),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor,
                                                constant: Config.pageControlOffset)
        ])

        pages.append(contentsOf: [
            OnboardingView(
                title: .localized(.onboardingSearchTitle),
                subtitle: .localized(.onboardingSearchContent),
                image: UIImage(named: "onboarding1") ?? UIImage()
            ),
            OnboardingView(
                title: .localized(.onboardingExploreTitle),
                subtitle: .localized(.onboardingExploreContent),
                image: UIImage(named: "onboarding2") ?? UIImage()
            )
//            OnboardingView(
//                title: .localized(.onboardingSwipeTitle),
//                subtitle: .localized(.onboardingSwipeContent),
//                image: UIImage(named: "onboarding3") ?? UIImage()
//            )
        ])

        pageControl.numberOfPages = pages.count
        pageViewController.setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
        pageViewController.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private enum Config {
        static let backgroundColor: UIColor = .clear
        static let pageControlOffset: CGFloat = -40
        static let buttonNextOffest: CGFloat = -20
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let viewController = pageViewController.viewControllers?.first else {
            return 0
        }
        guard let index = pages.firstIndex(of: viewController) else {
            return 0
        }

        return index
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            pageControl.currentPage = index
            if index == 1 {
                LocalNotificationManager.shared.requestAuthorization { granted in
                    CacheManager.shared.setNotifications(granted)
                }
                UserDefaults.standard.set(true, forKey: "onboardingFinished")
            }
        }
    }

    @objc private func nextButtonTapped() {
        if pageControl.currentPage == 1 {
            dismiss(animated: false)
            return
        }
        pageViewController.goToNextPage()
    }
}
