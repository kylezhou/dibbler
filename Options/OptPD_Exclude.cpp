/*
 * Dibbler - a portable DHCPv6
 *
 * author: Krzysztof Wnuk <keczi@poczta.onet.pl>
 * changes: Tomasz Mrugalski <thomson(at)klub.com.pl>
 *
 * released under GNU GPL v2 only licence
 *
 */

#include <string.h>
#include "Portable.h"
#include "DHCPConst.h"
#include "OptPD_Exclude.h"

TOptPD_Exclude::TOptPD_Exclude(const char * buf, size_t len, TMsg* parent)
    :TOpt(OPTION_PD_EXCLUDE, parent)
{
    if (len >= 2 && len <= 17) // prefix-len(1) + subnetID(1-16)
    {
        PDExcludeLen_  = *buf;
        buf += 1;
        len -= 1;

        PDExcludeSubnet_ = new TSubnetID(buf, len);
    }
}

TOptPD_Exclude::TOptPD_Exclude(SPtr<TSubnetID> subnetId, uint8_t len, TMsg* parent)
    :TOpt(OPTION_PD_EXCLUDE, parent), PDExcludeSubnet_(subnetId), PDExcludeLen_(len) {
    // we are not checking if subnetID is valid
}

size_t TOptPD_Exclude::getSize() {
    return 5 + PDExcludeSubnet_->getLen(); // option code (2) + option-len (2) + prefix-len (1) + subnetID
}

char * TOptPD_Exclude::storeSelf(char* buf)
{
    buf = writeUint16(buf, OptType);
    buf = writeUint16(buf, getSize() - 4);

    *(buf++) = PDExcludeLen_;

    buf = PDExcludeSubnet_->storeSelf(buf);
    return buf;
}

uint8_t TOptPD_Exclude::getPDExcludeLen() const {
    return PDExcludeLen_;
}

SPtr<TSubnetID> TOptPD_Exclude::getPDExcludeSubnet() const {
    return PDExcludeSubnet_;
}

void TOptPD_Exclude::setPDExcludeLen(uint8_t len){
    PDExcludeLen_ = len;
}

void TOptPD_Exclude::setPDExcludeSubnet(SPtr<TSubnetID> subnetId) {
    PDExcludeSubnet_ = subnetId;
}

void TOptPD_Exclude::setPDExcludeSubnet(const char * subnetId) {
    PDExcludeSubnet_ = new TSubnetID(subnetId);
}

bool TOptPD_Exclude::isValid() const {
    return (PDExcludeLen_ > 1 && PDExcludeLen_ < 128 &&
            PDExcludeSubnet_ && PDExcludeSubnet_->getLen());
}
