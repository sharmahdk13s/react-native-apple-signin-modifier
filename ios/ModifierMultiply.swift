import Foundation

@objc
public class ModifierMultiply: NSObject {
    @objc
    public func methodModifier(a: Double, b: Double) -> Double {
       return a * b
    }
}
