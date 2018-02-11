/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 *
 * released under GNU GPL v2 only licence
 *
 */

#include <string.h>
#include "hex.h"
#include "SubnetID.h"
#include "Logger.h"

using namespace std;

TSubnetID::TSubnetID()
{
}

// packed
TSubnetID::TSubnetID(const char* buf, int len)
{
    if (buf && len) {
        SubnetID_.resize(len);
        memcpy(&SubnetID_[0], buf, len);
        Plain_ = hexToText((uint8_t*)&SubnetID_[0], SubnetID_.size(), true);
    }
}

// plain
TSubnetID::TSubnetID(const char* text)
{
    if (!text) {
        return;
    }
    Log(Debug) << "TSubnetID(" << text << ")" << LogEnd;
    Plain_ = string(text);
    SubnetID_ = textToHex(Plain_);
    Plain_ = hexToText((uint8_t*)&SubnetID_[0], SubnetID_.size(), true);
}

TSubnetID::~TSubnetID() {
}

TSubnetID::TSubnetID(const TSubnetID &other) {
    SubnetID_ = other.SubnetID_;
    Plain_ = other.Plain_;
}

TSubnetID::TSubnetID(SPtr<TIPv6Addr> delegatedPrefix, uint8_t delegatedLen,
                     SPtr<TIPv6Addr> excludedPrefix, uint8_t excludedLen) {
    // sanity check
    if(excludedLen <= delegatedLen) {
        return;
    }
    if(delegatedLen < 1 || delegatedLen > 126) {
        return;
    }
    if(excludedLen < 2 || excludedLen > 127) {
        return;
    }
    TIPv6Addr dupExcludedPrefix(*excludedPrefix);
    dupExcludedPrefix.truncate(0, delegatedLen);
    if(dupExcludedPrefix != *delegatedPrefix) {
        return;
    }

    uint8_t subnetLenBits = excludedLen - delegatedLen;
    uint8_t subnetLenOctets = (subnetLenBits - 1 ) / 8 + 1; // subnet ID len in octets
    SubnetID_.resize(subnetLenOctets);
    uint8_t octOffset = delegatedLen / 8;
    uint8_t bitOffset = delegatedLen % 8;
    const char * exAddr = excludedPrefix->getAddr();
    uint8_t octIdx = 0;
    for(uint8_t octIdx = 0; octIdx < subnetLenOctets; octIdx++) {
        uint8_t tmp = 0;
        for(int i = 7; i >= 0; i--) {
            tmp |= ((exAddr[octOffset] >> (7-bitOffset)) & 1) << i;
            subnetLenBits--;
            if(subnetLenBits == 0) {
                break;
            }
            bitOffset++;
            if(bitOffset > 7) {
                octOffset++;
                bitOffset = 0;
            }
        }
        SubnetID_[octIdx] = tmp;
    }
    Plain_ = hexToText((uint8_t*)&SubnetID_[0], SubnetID_.size(), true);
}

TSubnetID& TSubnetID::operator=(const TSubnetID &other) {
    if (this == &other)
        return *this;

    SubnetID_ = other.SubnetID_;
    Plain_ = other.Plain_;

    return *this;
}

bool TSubnetID::operator==(const TSubnetID &other) {
    return (SubnetID_ == other.SubnetID_);
}

bool TSubnetID::operator<=(const TSubnetID &other) {

    return (SubnetID_ <= other.SubnetID_);
}

size_t TSubnetID::getLen() const {
    return SubnetID_.size();
}

const std::string TSubnetID::getPlain() const {
    return Plain_;
}

const char* TSubnetID::get() const {
    return (const char*)(&SubnetID_[0]);
}

char * TSubnetID::storeSelf(char *buf) {
    memcpy(buf, &SubnetID_[0], SubnetID_.size());
    return buf + SubnetID_.size();
}

ostream& operator<<(ostream &out, TSubnetID &subnetId) {
    if (subnetId.SubnetID_.size()) {
        out << "<SubnetID size=\"" << subnetId.SubnetID_.size() << "\">"
            << subnetId.Plain_ << "</SubnetID>";
    } else {
        out << "<SubnetID size=\"0\"></SubnetID>";
    }
    return out;
}
