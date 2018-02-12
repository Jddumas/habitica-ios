//
//  QuestProgressTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import YYImage

class QuestProgressView: UIView {
    
    @IBOutlet weak var questImageView: YYAnimatedImageView!
    @IBOutlet weak var healthProgressView: QuestProgressBarView!
    @IBOutlet weak var rageProgressView: QuestProgressBarView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var descriptionSeparator: UIView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var descriptionTitleView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var carretIconView: UIImageView!
    @IBOutlet weak var descriptionTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTitleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bossArtTitle: UIView!
    @IBOutlet weak var bossArtTitleLabel: PaddedLabel!
    @IBOutlet weak var bossArtCreditLabel: UILabel!
    @IBOutlet weak var bossArtTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bossArtCarret: UIImageView!
    @IBOutlet weak var questArtSeparator: UIView!
    
    @IBOutlet weak var rageStrikeCountLabel: UILabel!
    @IBOutlet weak var rageStrikeCountLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var rageStrikeContainer: UIStackView!
    @IBOutlet weak var rageStrikeContainerHeight: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = true
            
            view.frame = bounds
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            addSubview(view)
            
            bossArtTitleHeightConstraint.constant = 46
            bossArtTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bossArtTitleTapped)))
            bossArtCarret.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            healthProgressView.barColor = UIColor.red50()
            healthProgressView.icon = HabiticaIcons.imageOfHeartLightBg
            healthProgressView.pendingBarColor = UIColor.red10().withAlphaComponent(0.3)
            healthProgressView.pendingIcon = HabiticaIcons.imageOfDamage
            healthProgressView.pendingTitle = "dmg pending"
            rageProgressView.barColor = UIColor.orange100()
            rageProgressView.icon = #imageLiteral(resourceName: "icon_rage")
            rageStrikeCountLabelHeight.constant = 30
            rageStrikeContainerHeight.constant = 84
            rageStrikeCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rageStrikeButtonTapped)))
            
            contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            contentStackView.isLayoutMarginsRelativeArrangement = true
            
            descriptionTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descriptionTitleTapped)))
            descriptionTitleHeightConstraint.constant = 47
            descriptionTitleTopConstraint.constant = 8
            descriptionTextView.contentInset = UIEdgeInsets.zero
            carretIconView.tintColor = .white
            carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            bossArtTitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            descriptionTitle.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            rageStrikeCountLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            bossArtCreditLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            
            let userDefaults = UserDefaults()
            if userDefaults.bool(forKey: "worldBossArtCollapsed") {
                hideBossArt()
            }
            if userDefaults.bool(forKey: "worldBossDescriptionCollapsed") {
                hideDescription()
            }
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    @objc
    func configure(quest: Quest) {
        healthProgressView.title = quest.bossName ?? ""
        healthProgressView.maxValue = quest.bossHp?.floatValue ?? 0
        if let bossRage = quest.bossRage?.floatValue, bossRage > 0 {
            rageProgressView.maxValue = quest.bossRage?.floatValue ?? 0
            rageProgressView.title = NSLocalizedString("Rage attack: \(quest.rageTitle ?? "")", comment: "")
        } else {
            rageProgressView.isHidden = true
        }
        HRPGManager.shared().setImage("quest_" + quest.key, withFormat: "gif", on: questImageView)
        
        let colorDark = quest.uicolorDark
        let colorMedium = quest.uicolorMedium
        let colorLight = quest.uicolorLight
        let colorExtraLight = quest.uicolorExtraLight
        self.backgroundView.image = HabiticaIcons.imageOfQuestBackground(bossColorDark: colorDark,
                                                                         bossColorMedium: colorMedium,
                                                                         bossColorLight: colorExtraLight)
            .resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10),
                            resizingMode: UIImageResizingMode.stretch)
        
        gradientView.endColor = colorLight
        descriptionSeparator.backgroundColor = colorLight
        questArtSeparator.backgroundColor = colorLight
        let description = try? Down(markdownString: quest.notes.replacingOccurrences(of: "<br>", with: "\n")).toHabiticaAttributedString()
        description?.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: description?.length ?? 0))
        descriptionTextView.attributedText = description
        
        bossArtCarret.tintColor = colorExtraLight
        bossArtCreditLabel.textColor = colorExtraLight
        
        for view in rageStrikeContainer.arrangedSubviews {
            if let rageStrikeView = view as? RageStrikeView {
                rageStrikeView.bossName = quest.bossName ?? ""
                rageStrikeView.questIdentifier = quest.key ?? ""
            }
        }
    }
    
    @objc
    func configure(group: Group) {
        healthProgressView.currentValue = group.questHP?.floatValue ?? 0
        rageProgressView.currentValue = group.questRage?.floatValue ?? 0
        
        rageStrikeCountLabel.text = "Rage Strikes: \(group.rageStrikeCount)/\(group.totalRageStrikes)"
        
        rageStrikeContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if let rageStrikes = group.rageStrikes {
            for rageStrike in rageStrikes {
                let rageStrikeView = RageStrikeView()
                rageStrikeView.locationIdentifier = rageStrike.key
                rageStrikeView.isActive = rageStrike.value.boolValue
                rageStrikeContainer.addArrangedSubview(rageStrikeView)
            }
        }
    }
    
    @objc
    func configure(user: User) {
        healthProgressView.pendingValue = user.pendingDamage.floatValue
    }
    
    @objc
    func descriptionTitleTapped() {
        if descriptionTextView.isHidden {
            showDescription()
        } else {
            hideDescription()
        }
    }
    
    private func showDescription() {
        carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
        descriptionTextView.isHidden = false
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossDescriptionCollapsed")
    }
    
    private func hideDescription() {
        carretIconView.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        descriptionTextView.isHidden = true
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "worldBossDescriptionCollapsed")
    }
    
    @objc
    func bossArtTitleTapped() {
        if questImageView.isHidden {
            showBossArt()
        } else {
            hideBossArt()
        }
    }
    
    private func showBossArt() {
        bossArtCarret.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
        questImageView.isHidden = false
        gradientView.isHidden = false
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossArtCollapsed")
    }
    
    private func hideBossArt() {
        bossArtCarret.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        questImageView.isHidden = true
        gradientView.isHidden = true
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "worldBossArtCollapsed")
    }
    
    @objc
    func rageStrikeButtonTapped() {
        let string = NSLocalizedString("There are 3 potential Rage Strikes\nThis gauge fills when Habiticans miss their Dailies. If it fills up, the DysHeartener will unleash its Shattering Heartbreak attack on one of Habitica's shopkeepers, so be sure to do your tasks!", comment: "")
        let attributedString = NSMutableAttributedString(string: string)
        let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
        attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 17), range: firstLineRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
        attributedString.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: 15), range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
        let alertController = HabiticaAlertController.alert(title: NSLocalizedString("What's a Rage Strike?", comment: ""), attributedMessage: attributedString)
        alertController.titleBackgroundColor = UIColor.orange50()
        alertController.addCloseAction()
        alertController.show()
        alertController.titleLabel.textColor = .white
    }
}