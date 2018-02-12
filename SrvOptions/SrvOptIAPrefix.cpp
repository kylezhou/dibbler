/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 * changes: Krzysztof Wnuk <keczi@poczta.onet.pl>
 *
 *
 */

#include "DHCPConst.h"
#include "Opt.h"
#include "OptIAPrefix.h"
#include "SrvOptIAPrefix.h"
#include "OptStatusCode.h"
#include "Msg.h"
#include "Logger.h"
#include "Portable.h"
#include "OptPD_Exclude.h"

TSrvOptIAPrefix::TSrvOptIAPrefix( char * buf, int bufsize, TMsg* parent)
    :TOptIAPrefix(buf,bufsize, parent)
{
}

TSrvOptIAPrefix::TSrvOptIAPrefix(SPtr<TIPv6Addr> prefix, char length, unsigned long pref,
                                   unsigned long valid, TMsg* parent)
    :TOptIAPrefix(prefix,length,pref,valid, parent) {
}

TSrvOptIAPrefix::TSrvOptIAPrefix(SPtr<TIPv6Addr> prefix, char length,
                                 unsigned long pref, unsigned long valid,
                                 SPtr<TSubnetID> excludeSubnet, uint8_t excludeLen,
                                 TMsg* parent)
    :TOptIAPrefix(prefix, length, pref, valid, parent) {
    SPtr<TOptPD_Exclude> opt = new TOptPD_Exclude(excludeSubnet, excludeLen, parent);
    // do not append invalid PD-EXCLUDE
    if(opt->isValid()) {
        SubOptions.append(SPtr_cast<TOpt>(opt));
    }
}

bool TSrvOptIAPrefix::doDuties() {
    return true;
}
