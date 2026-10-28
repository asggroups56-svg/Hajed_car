/// Which salary-transfer term set an offer should be presented with.
///
/// The offers endpoints return two parallel sets of terms: the standard fields
/// (salary transferred to the bank/provider) and the `*Other` fields (salary
/// transferred to another bank).
enum SalaryTransferType { transferred, nonTransferred }
