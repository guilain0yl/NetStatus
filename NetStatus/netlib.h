//
//  netlib.h
//  PCStatus
//
//  Created by guilain yl on 2021/8/9.
//

#ifndef netlib_h
#define netlib_h

typedef void (*p_callback)(const char*,unsigned int,unsigned int,void *);

extern int request_net_speed(p_callback func,void* obj);

#endif /* netlib_h */
