import SwiftUI

/// LectraColors provides a consistent color scheme across the app
enum LectraColors {
    // MARK: - Brand Colors
    
    /// Main brand color - #1E3A8A
    static let brand = Color("Brand", bundle: .main)
    static let brandSecondary = brand.opacity(0.8)
    static let brandLight = brand.opacity(0.2)
    
    // MARK: - UI Colors
    
    /// Background colors
    static let background = Color("Background", bundle: .main)
    static let secondaryBackground = Color(.secondarySystemBackground)
    
    /// Text colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    
    // MARK: - Utility Colors
    
    /// Status colors
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    
    /// UI element colors
    static let separator = Color(.separator)
    static let disabled = Color(.systemGray4)
} 