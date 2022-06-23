import Foundation

extension Date {
  init(nsSince1970 ns: Int) {
    self.init(timeIntervalSince1970: TimeInterval(ns) / TimeInterval(NSEC_PER_SEC))
  }
}
