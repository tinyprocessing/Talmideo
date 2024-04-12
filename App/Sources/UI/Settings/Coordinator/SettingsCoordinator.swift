import Combine
import Foundation
import UIKit

class SettingsCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SettingsViewController?
    private var bookmarks = BookmarkManager()
    private var context: CurrentValueSubject<TalmideoContext, Never>

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
        }

        let title: String
        let actionButtonTitle: String
        let isActionDanger: Bool
        let action: (() -> Void)?
        let type: SettingsType

        init(
            title: String,
            actionButtonTitle: String,
            isActionDanger: Bool = false,
            action: (() -> Void)?,
            type: SettingsType = .general
        ) {
            self.title = title
            self.actionButtonTitle = actionButtonTitle
            self.action = action
            self.isActionDanger = isActionDanger
            self.type = type
        }
    }

    private lazy var settingsSections: [SettingsSectionModel] = [
        SettingsSectionModel(
            title: .localized(.generalSettings),
            options: [.init(title: .localized(.notifications), actionButtonTitle: "", action: nil),
                      .init(
                          title: .localized(.bookmarks),
                          actionButtonTitle: "\(bookmarks.count)",
                          action: nil,
                          type: .bookmarks
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

    init?(router: Router, context: CurrentValueSubject<TalmideoContext, Never>) {
        self.router = router
        self.context = context
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
