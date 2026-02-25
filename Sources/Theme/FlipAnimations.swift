import SwiftUI

extension Animation {
    static let flipBounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let flipSnap   = Animation.spring(response: 0.3, dampingFraction: 0.8)
}
