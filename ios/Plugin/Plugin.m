#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(EhrPlugin, "EhrPlugin",
           CAP_PLUGIN_METHOD(authorize, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(querySampleType, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getRequestStatusForAuthorization, CAPPluginReturnPromise);
           )
