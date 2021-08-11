//
//  netlib.c
//  PCStatus
//
//  Created by guilain yl on 2021/8/9.
//

#include "netlib.h"
#include<ifaddrs.h>
#include<net/if.h>
#include<stdlib.h>

int request_net_speed(p_callback func,void* obj)
{
    struct ifaddrs *ifa_list=NULL;
    struct ifaddrs *ifa=NULL;
    struct if_data *ifd=NULL;
    int ret=0;
    
    ret=getifaddrs(&ifa_list);
    if(ret<0) return -1;
    
    for(ifa=ifa_list;ifa;ifa=ifa->ifa_next)
    {
        if(!(ifa->ifa_flags&IFF_UP)&&!(ifa->ifa_flags&IFF_RUNNING))
            continue;
        
        if(ifa->ifa_data==0)
            continue;
        
        ifd=(struct if_data*)ifa->ifa_data;
        
        func(ifa->ifa_name,ifd->ifi_ibytes,ifd->ifi_obytes,obj);
    }
    
    ifa=NULL;
    ifd=NULL;
    free(ifa_list);
    
    return 0;
}
