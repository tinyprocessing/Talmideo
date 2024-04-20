import Combine
import Foundation
import UIKit

class SettingsCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SettingsViewController?
    private var bookmarks = BookmarkManager()
    private var context: CurrentValueSubject<TalmideoContext, Never>
    private let analytics: TalmideoAnalytics

    deinit {
        print(Self.self, "deinit")
    }

    struct SettingsSectionModel {
        let title: String
        let options: [SettingsCellModel]
    }

    struct SettingsModel {
        let settingsSections: [SettingsSectionModel]
    }

    struct SettingsCellModel {
        enum SettingsType {
            case bookmarks
            case general
            case swipeNotifications
            case swipeSpeech
            case swipeSounds
        }

        let title: String
        let actionButtonTitle: String
        let isActionDanger: Bool
        let action: (() -> Void)?
        let type: SettingsType
        let swipeDefaultValue: Bool
        let swipeActionTrue: (() -> Void)?
        let swipeActionFalse: (() -> Void)?

        init(
            title: String = "",
            actionButtonTitle: String = "",
            isActionDanger: Bool = false,
            action: (() -> Void)? = nil,
            type: SettingsType = .general,
            swipeDefaultValue: Bool = false,
            swipeActionTrue: (() -> Void)? = nil,
            swipeActionFalse: (() -> Void)? = nil
        ) {
            self.title = title
            self.actionButtonTitle = actionButtonTitle
            self.isActionDanger = isActionDanger
            self.action = action
            self.type = type
            self.swipeDefaultValue = swipeDefaultValue
            self.swipeActionTrue = swipeActionTrue
            self.swipeActionFalse = swipeActionFalse
        }
    }

    private lazy var settingsSections: [SettingsSectionModel] = [
        SettingsSectionModel(
            title: .localized(.generalStatistics),
            options: [.init(
                title: .localized(.bookmarks),
                actionButtonTitle: "\(bookmarks.count)",
                action: nil,
                type: .bookmarks
            ), .init(
                title: .localized(.notifications),
                action: nil,
                type: .swipeNotifications,
                swipeDefaultValue: CacheManager.shared.getNotifications(),
                swipeActionTrue: { [weak self] in
                    guard let self = self else { return }
                    CacheManager.shared.setNotifications(true)
                    context.send(.init(state: .notifications))
                },
                swipeActionFalse: { [weak self] in
                    guard let self = self else { return }
                    CacheManager.shared.setNotifications(false)
                    context.send(.init(state: .notifications))
                }
            ), .init(
                title: .localized(.autoSpeech),
                type: .swipeSpeech,
                swipeDefaultValue: CacheManager.shared.getAutoSpeech(),
                swipeActionTrue: {
                    CacheManager.shared.setAutoSpeech(true)
                },
                swipeActionFalse: {
                    CacheManager.shared.setAutoSpeech(false)
                }
            ), .init(
                title: .localized(.sounds),
                type: .swipeSounds,
                swipeDefaultValue: CacheManager.shared.getSounds(),
                swipeActionTrue: {
                    CacheManager.shared.setSounds(true)
                },
                swipeActionFalse: {
                    CacheManager.shared.setSounds(false)
                }
            )]
        ),
        SettingsSectionModel(
            title: .localized(.advancedSettings),
            options: [.init(
                title: .localized(.clearHistory),
                actionButtonTitle: .localized(.delete),
                isActionDanger: true,
                action: { [weak self] in
                    guard let self = self else { return }
                    analytics.trackEvent(with: .settings, event: .bookmarksRemove)
                    bookmarks.removeAll()
                    context.send(.init(state: .bookmarks))
                }
            )]
        ),
        SettingsSectionModel(
            title: .localized(.contact),
            options: [.init(title: .localized(.github), actionButtonTitle: .localized(.open), action: {
                if let url = URL(string: "https://github.com/tinyprocessing") {
                    UIApplication.shared.open(url)
                }
            }),
            .init(title: .localized(.website), actionButtonTitle: .localized(.open), action: {
                if let url = URL(string: "https://tinyprocessing.com") {
                    UIApplication.shared.open(url)
                }
            }),
            .init(title: .localized(.mail), actionButtonTitle: .localized(.send), action: {
                if let url = URL(string: "https://tinyprocessing.com/connect") {
                    UIApplication.shared.open(url)
                }
            })]
        )
    ]

    init?(router: Router, context: CurrentValueSubject<TalmideoContext, Never>, analytics: TalmideoAnalytics) {
        self.router = router
        self.context = context
        self.analytics = analytics
        super.init()
        viewController = SettingsViewController(SettingsModel(settingsSections: settingsSections), context: context)
    }

    override func start() {
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}
