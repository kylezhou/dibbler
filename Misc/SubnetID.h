/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 *
 * Released under GNU GPL v2 licence
 *
 */

class TSubnetID;
#ifndef SUBNETID_H_
#define SUBNETID_H_
#include <vector>
#include <string>
#include <stdint.h>
#include "IPv6Addr.h"

class TSubnetID
{
    friend std::ostream& operator<<(std::ostream& out,TSubnetID &subnetId);
 public:
    TSubnetID(); // @todo: remove this
    TSubnetID(const char* buf,int len); // packed
    TSubnetID(const char* text); // plain
    TSubnetID(const TSubnetID &subnetId);
    TSubnetID(SPtr<TIPv6Addr> delegatedPrefix, uint8_t delegatedLen, SPtr<TIPv6Addr> excludedPrefix, uint8_t excludedLen);
    TSubnetID& operator=(const TSubnetID& subnetId);
    bool operator==(const TSubnetID &subnetId);
    bool operator<=(const TSubnetID &subnetId);
    size_t getLen() const;
    const std::string getPlain() const;
    char * storeSelf(char* buf);
    const char * get() const;

    ~TSubnetID();

private:
    std::vector<uint8_t> SubnetID_;
    std::string Plain_;
};

#endif
