//
//  OnboardingSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 15.09.2022.
//

import UIKit
import AppTrackingTransparency

class OnboardingSceneView: UIViewController, UD, Routerable, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum CellType {
        case whatIsMeta
        case howItWorks
        case problems
        
        var title: NSAttributedString {
            switch self {
            case .whatIsMeta:
                return NSAttributedString(string: Constants.Onboarding.whatIsMetaTitle)
            case .howItWorks:
                return NSAttributedString(string:Constants.Onboarding.howItWorksTitle)
            case .problems:
                return NSAttributedString(string:Constants.Onboarding.problemsTitle)
            }
        }
        
        var image: UIImage {
            switch self {
            case .whatIsMeta:
                return AppImages.vault
            case .howItWorks:
                return UIImage()
            case .problems:
                return UIImage()
            }
        }
        
        var subTitle: NSAttributedString {
            switch self {
            case .whatIsMeta:
                return Constants.Onboarding.whatIsMetaSubTitle.withBoldText(boldPartsOfString: (Constants.Onboarding.whatIsMetaSubTitleComponents as Array<NSString>), font: UIFont.avenirMedium(size: Config.subtitleFont), boldFont: UIFont.avenirBold(size: Config.subtitleFont))
            case .howItWorks:
                return Constants.Onboarding.howItWorksSubTitle.withBoldText(boldPartsOfString: (Constants.Onboarding.howItWorksSubTitleComponents as Array<NSString>), font: UIFont.avenirMedium(size: Config.subtitleFont), boldFont: UIFont.avenirBold(size: Config.subtitleFont))
            case .problems:
                return Constants.Onboarding.problemsSubTitle.withBoldText(boldPartsOfString: (Constants.Onboarding.problemsSubTitleComponents as Array<NSString>), font: UIFont.avenirMedium(size: Config.subtitleFont), boldFont: UIFont.avenirBold(size: Config.subtitleFont))
            }
        }
        
        var description: String {
            switch self {
            case .whatIsMeta:
                return Constants.Onboarding.whatIsMetaMessage
            case .howItWorks:
                return Constants.Onboarding.howItWorksMessage
            case .problems:
                return Constants.Onboarding.problemsMessage
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    private let cells: [CellType] = [.whatIsMeta, .howItWorks, .problems]
    
    private struct Config {
        static let subtitleFont: CGFloat = 20
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        pageControl.numberOfPages = cells.count
        checkButtonsAvailability()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Functions
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(nibWithCellClass: OnboardingCollectionViewCell.self)
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: Any) {
        finishOnboarding()
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        finishOnboarding()
    }
    
    @IBAction func previousPageButtonTapped(_ sender: Any) {
        let prevPage = pageControl.currentPage - 1
        guard prevPage >= 0 else { return }
        collectionView.scrollToItem(at: IndexPath(row: prevPage, section: 0), at: .right, animated: true)
    }
    
    @IBAction func nextPageButtonTapped(_ sender: Any) {
        let nextPage = pageControl.currentPage + 1
        guard nextPage < pageControl.numberOfPages else { return }
        collectionView.scrollToItem(at: IndexPath(row: nextPage, section: 0), at: .left, animated: true)
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: OnboardingCollectionViewCell.self, for: indexPath)
        cell.setup(cellType: cells[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page
        checkButtonsAvailability()
    }
}

private extension OnboardingSceneView {
    func checkButtonsAvailability() {
        let page = pageControl.currentPage
        switch page {
        case cells.count - 1:
            nextPageButton.isHidden = true
            previousPageButton.isHidden = false
        case 0:
            nextPageButton.isHidden = false
            previousPageButton.isHidden = true
        default:
            nextPageButton.isHidden = false
            previousPageButton.isHidden = false
        }
    }
    
    func finishOnboarding() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization() { _ in
                DispatchQueue.main.async {
                    self.routeTo(.login, presentAs: .root)
                }
            }
        } else {
            routeTo(.login, presentAs: .root)
        }
        shouldShowOnboarding = false
    }
}