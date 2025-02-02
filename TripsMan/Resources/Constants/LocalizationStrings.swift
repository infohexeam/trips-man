//
//  LocalizationStrings.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/07/23.
//

import Foundation

struct L {
    static func reviewedByText(by customerName: String, on reviewDate: String) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "- تمت المراجعة بواسطة \(customerName) بتاريخ \(reviewDate)"
        } else {
            return "- Reviewed by \(customerName) on \(reviewDate)"
        }
    }
    
    static func addGuestValidationMessage(guestCount: Int) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "لقد اخترت \(guestCount) شخصًا فقط"
        } else {
            if guestCount == 1 {
                return "You have selected only 1 person"
            } else {
                return "You have selected only \(guestCount) people"
            }
        }
    }
    
    static func roomAndGuestCountText(roomCount: Int, adultCount: Int, childCount: Int) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "\(roomCount.oneOrMany("Room")) مقابل \(adultCount.oneOrMany("Adult")) و \(childCount.oneOrMany("Child", suffix: "ren"))"
        } else {
            return "\(roomCount.oneOrMany("Room")) for \(adultCount.oneOrMany("Adult")) and \(childCount.oneOrMany("Child", suffix: "ren"))"
        }
    }
    
    static func redeemRewardPointText(percentage: Double, maxAmount: Double) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "استبدل \(percentage)٪ من نقاط محفظتك. الحد الأقصى لمبلغ الاسترداد في هذا الحجز هو \(maxAmount.attachCurrency)"
        } else {
            return "Redeem \(percentage)% of your wallet points. Maximum redeem amount on this booking is \(maxAmount.attachCurrency)"
        }
    }
    
    static func bookingSuccessMessage(for module: String, with bookingNo: String) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "تم تأكيد حجزك \(K.getModuleText(of: module)) بنجاح. استمتع بتجربتك! رقم الحجز: \(bookingNo))"
        } else {
            return "Your \(K.getModuleText(of: module)) booking has been successfully confirmed. Enjoy your experience! Booking No: \(bookingNo)"
        }
        
    }
    
    static func paymentWaitingMessage(for module: String, with bookingNo: String) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "تم تأكيد حجزك رقم \(K.getModuleText(of: module)) بنجاح. والتحقق من الدفع قيد المعالجة. إذا كانت لديك أي أسئلة أو كنت بحاجة إلى المساعدة ، فاتصل بالمسؤول لدينا على الرقم \(K.adminContactNo) أو \(K.adminContactEmail).\nرقم الحجز: \(bookingNo)"
        }
        return "Your \(K.getModuleText(of: module)) booking has been successfully confirmed. And payment verification is in process. If you have any questions or need assistance, contact our admin at \(K.adminContactNo) or \(K.adminContactEmail).\nBooking No: \(bookingNo)"
    }
    
    static func bookingFailedMessage() -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return "نعتذر ، ولكن يبدو أن هناك مشكلة في حجزك. للأسف ، لا يمكن تأكيد الحجز في هذا الوقت. نوصي بالاتصال بفريق الدعم للحصول على مزيد من المساعدة. ونحن نعتذر عن أي إزعاج. اتصل بنا على \(K.adminContactNo) أو \(K.adminContactEmail)"
        }
        return "We apologise, but there seems to be an issue with your booking. Unfortunately, the booking could not be confirmed at this time. We recommend contacting our support team for further assistance. We apologize for any inconvenience caused. Contact us at \(K.adminContactNo) or \(K.adminContactEmail)"
    }
}
