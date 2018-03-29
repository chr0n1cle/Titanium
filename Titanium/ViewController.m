//
//  ViewController.m
//  Titanium
//
//  Created by Chronicle on 20/03/18.
//  Copyright © 2018 chr0n1cle. All rights reserved.
//

#include <pthread.h>
#include <mach/mach.h>

#import "ViewController.h"
#import "common.h"
#import "offsets.h"
#include "unjail.h"
#import "v0rtex.h"

@interface ViewController ()

@end

kern_return_t cb(task_t tfp0, kptr_t kbase, void *data)
{
    FILE *f = fopen("/var/mobile/test.txt", "w");
    LOG("file: %p", f);
    
    host_t host = mach_host_self();
    mach_port_t name = MACH_PORT_NULL;
    kern_return_t ret = processor_set_default(host, &name);
    LOG("processor_set_default: %s", mach_error_string(ret));
    if(ret == KERN_SUCCESS)
    {
        mach_port_t priv = MACH_PORT_NULL;
        ret = host_processor_set_priv(host, name, &priv);
        LOG("host_processor_set_priv: %s", mach_error_string(ret));
        if(ret == KERN_SUCCESS)
        {
            task_array_t tasks;
            mach_msg_type_number_t num;
            ret = processor_set_tasks(priv, &tasks, &num);
            LOG("processor_set_tasks: %u, %s", num, mach_error_string(ret));
        }
    }
    
    return KERN_SUCCESS;
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)jailbreak:(UIButton *)sender {
    kern_return_t ret = KERN_SUCCESS;
    
    offsets_t *off = get_offsets();
    
    if(off)
    {
        NSLog(@"[Info]: start exploit");
        ret = v0rtex(off, &cb, NULL);
    }
    
    if(ret != KERN_SUCCESS) {
        NSLog(@"[Info]: fail exploit");
        
    } else {
        // go to memprot bypass
        NSLog(@"[Info]: start bypass");
        [self memprot_bypass];
    }
}

- (void) memprot_bypass {
    if (go_bypass() == KERN_SUCCESS) {
        NSLog(@"[Info]: success jailbreak");
        
    } else {
        NSLog(@"[Info]: fail bypass");
        }
}

@end
