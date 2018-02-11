/*
 * Dibbler - a portable DHCPv6
 *
 * author: Krzysztof Wnuk <keczi@poczta.onet.pl>
 *
 * released under GNU GPL v2 only licence
 *
 *
 */

#ifndef OPTPD_EXCLUDE_H
#define OPTPD_EXCLUDE_H

#include "SmartPtr.h"
#include "Container.h"
#include "Opt.h"
#include "SubnetID.h"

class TOptPD_Exclude : public TOpt
{
  public:
    TOptPD_Exclude(const char * buf, size_t len, TMsg* parent);
    TOptPD_Exclude(SPtr<TSubnetID> subnetId, uint8_t len, TMsg* parent);
    size_t getSize();

    char * storeSelf( char* buf);
    uint8_t getPDExcludeLen() const;
    SPtr<TSubnetID> getPDExcludeSubnet() const;
    void setPDExcludeLen(uint8_t len);
    void setPDExcludeSubnet(SPtr<TSubnetID> subnetId);
    void setPDExcludeSubnet(const char * subnetId);
    virtual bool isValid() const;
    virtual bool doDuties() { return true; }

 private:
    SPtr<TSubnetID> PDExcludeSubnet_; // 1 to 16 bytes
    uint8_t PDExcludeLen_; // the length of the excluded prefix in bits
};

#endif
