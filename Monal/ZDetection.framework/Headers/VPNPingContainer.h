//
//  VPNPingContainer.hpp
//  zIPS-ZDetection
//
//  Created by Jae Han on 1/15/21.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

#ifndef VPNPingContainer_hpp
#define VPNPingContainer_hpp

#include <stdio.h>
#include <string>
#include <memory>
#include "ModuleInterfaces.h"

class VPNPingError : public IError {
    NSError* _error;
public:
    VPNPingError(NSError* error) {
        _error = error;
    }
    virtual ~VPNPingError() {}
    
    long code();
    std::string reason();
};

class VPNPingContainer : public IVPNPing {
public:
    virtual ~VPNPingContainer() {}

    void test_running_cb(std::function<void(bool, std::shared_ptr<IError>)> callback);
    void set_completion_func(std::function<void(bool, std::shared_ptr<IError>)> callback) {
        _callback = callback;
    }
    void test_running();
    
};

#endif /* VPNPingContainer_hpp */
