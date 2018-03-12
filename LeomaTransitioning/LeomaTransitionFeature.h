//
//  LeomaTransitionFeature.h
//  LeomaFramework
//
//  Created by CorpDev on 2018/1/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LeomaTransitionAction){
    LeomaTransitionActionPush,  //default action, will push in or pop out the target VC, the default transition style is LeomaTransitionPerformanceHorizontalDefault
    LeomaTransitionActionModal, //modal action, will modal in or out the target VC (won't affect the default stack), the default transition style is LeomaTransitionPerformaceVerticalDefault
    LeomaTransitionActionTab,   //replace action, will replace the sender VC from default stack or the modal VC to the taret VC, the default transition style is LeomaTransitionPerformaceTabbedDefault
};

typedef NS_ENUM(NSInteger, LeomaTransitionPerformace){
    /*! @breif a transition performance whose animtor will preform horizontally
     
     @b duration: 500ms for 100% animation.
     
     @b springing: no springing.
     
     @b presenting: sender from {0, 0} to {-50%, 0}. target from {100%, 0} to {0, 0}.
     
     @b dismissing: sender from {0, 0} to {100%, 0}. target from {-50%, 0} to {0, 0}.
     
     @see LeomaTrasitionContext
     */
    LeomaTransitionPerformanceHorizontalDefault,
    /*! @brief a transition style whose animtor will preform vertically
     
     @b duration: 500ms for 100% animation.
     
     @b springing: no springing.
     
     @b presenting: sender from {0, 0} to {0, 0}. target from {0, 100%} to {0, 0}.
     
     @b dismissing: sender from {0, 0} to {0, 100%}. target from {0, 0} t0 {0, 0}.
     */
    LeomaTransitionPerformaceVerticalDefault,
    /*! @brief a transition style of no animation*/
    LeomaTransitionPerformaceTabbedDefault,
};
