import SwiftUI
import UIKit

@available(iOS 13.0, *)
/// A `View` wrapper for `UIPageViewController` which lets you write 📝 and use 🔨 a page view in SwiftUI.
///
/// Binds to a zero-indexed 0️⃣1️⃣2️⃣ "current page" `Int`eger.
public struct iPages<Content: View>: View {
    @State private var viewControllers: [UIViewController]
    
    @State private var internalSelection: Int = 0
    @Binding private var externalSelection: Int
    private var selection: Binding<Int> {
        hasExternalSelection ? $externalSelection : $internalSelection
    }
    private var hasExternalSelection = false
    
    var showsPageControl: Bool = true
    
    // Page view controller
    var pageViewControllerWraps: Bool = false
    var pageViewControllerNavigationOrientation: UIPageViewController.NavigationOrientation = .horizontal
    var pageViewControllerBounce: Bool = true
    var pageViewControllerInterPageSpacing: CGFloat = 0
    var pageViewAnimated: Bool = true
    private var pageViewController: PageViewController {
        .init(controllers: viewControllers,
              currentPage: selection,
              wraps: pageViewControllerWraps,
              navigationOrientation: pageViewControllerNavigationOrientation,
              bounce: pageViewControllerBounce,
              interPageSpacing: pageViewControllerInterPageSpacing,
              animated: pageViewAnimated)
    }
    
    // Page control
    var pageControlHidesForSinglePage: Bool = false
    var pageControlCurrentPageIndicatorTintColor: UIColor?
    var pageControlPageIndicatorTintColor: UIColor?
    private var _pageControlBackgroundStyle: Any? = nil
    @available(iOS 14, *)
    var pageControlBackgroundStyle: UIPageControl.BackgroundStyle {
        get {
            guard _pageControlBackgroundStyle != nil else {
                return .automatic
            }
            return _pageControlBackgroundStyle as! UIPageControl.BackgroundStyle
        }
        set(newStyle) {
            _pageControlBackgroundStyle = newStyle
        }
    }
    var pageControlAllowsContinuousInteraction: Bool = false
    var pageControlAlignment: Alignment = .bottom
    private var pageControl: PageControl {
        if #available(iOS 14.0, *) {
            return .init(numberOfPages: viewControllers.count,
                         currentPage: selection,
                         hidesForSinglePage: pageControlHidesForSinglePage,
                         pageIndicatorTintColor: pageControlPageIndicatorTintColor,
                         currentPageIndicatorTintColor: pageControlCurrentPageIndicatorTintColor,
                         backgroundStyle: pageControlBackgroundStyle,
                         allowsContinuousInteraction: pageControlAllowsContinuousInteraction)
        } else {
            return .init(numberOfPages: viewControllers.count,
                         currentPage: selection,
                         hidesForSinglePage: pageControlHidesForSinglePage,
                         pageIndicatorTintColor: pageControlPageIndicatorTintColor,
                         currentPageIndicatorTintColor: pageControlCurrentPageIndicatorTintColor,
                         allowsContinuousInteraction: pageControlAllowsContinuousInteraction)
        }
    }
    
    /// Initializes the page 📃📖 view. 👷‍♀️
    /// - Parameters:
    ///   - selection: A binding to the page that the user is currently on ⌚️, zero indexed (meaning page 1 is 0, page 2 is 1, etc.)
    ///   - content: The ordered view builder of `View`s to appear in the page view 📑
    public init(selection: Binding<Int>? = nil,
                @ViewBuilder content: () -> Content)
    {
        _viewControllers = State(initialValue: content().decompose().map { UIHostingController(rootView: $0) })
        if let selection = selection {
            _externalSelection = selection
            hasExternalSelection = true
        } else {
            _externalSelection = Binding<Int>(get: { 0 }, set: { _ in })
        }
    }
        
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
        
    public var body: some View {
        ZStack(alignment: pageControlAlignment) {
            pageViewController
            if showsPageControl {
                switch pageControlAlignment {
                case .leading, .trailing:
                    VStack {
                        if pageControlAlignment == .leading { Spacer() }
                        pageControl
                        if pageControlAlignment == .trailing { Spacer() }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .rotationEffect(.degrees(layoutDirection ~= .leftToRight ? 90 : -90))
                default:
                    pageControl
                        .fixedSize()
                        .padding(.vertical)
                }
            }
        }
    }
}
