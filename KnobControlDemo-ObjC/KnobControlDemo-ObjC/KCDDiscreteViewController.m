/*
 Copyright (c) 2013-14, Jimmy Dee
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "IOSKnobControl.h"
#import "KCDDiscreteViewController.h"

/*
 * The purpose of the discrete demo is to exercise the knob control in the discrete
 * modes ICKModeLinearReturn and ICKModeWheelOfFortune. A segmented control selects between these
 * modes. This view includes a single knob control with two output fields in the upper
 * right: position and index. The index field displays the value of the knob's positionIndex
 * property, which is not available in ICKModeContinous or ICModeRotaryDial mode. In addition, the
 * following controls configure the knob control's behavior:
 * - a switch labeled "clockwise" that determines whether the knob considers a positive rotation to be clockwise or counterclockwise
 * - a segmented control to select which gesture the knob will respond to (1-finger rotation, 2-finger rotation, vertical pan or tap)
 * - a slider labeled "time scale" that specifies the timeScale property of the knob control (for return animations, which only occur in discrete modes)
 * - a segmented control to select between two different sets of demo images
 * -- months: the control generates the knob image from the knob's titles property; the user can select any month from the knob
 * -- hexagon: the control uses one of two image sets from the asset catalog, each a hexagon with index values printed around the sides; changing the
 *    clockwise setting switches to a different image with numbers rendered in the opposite direction
 */
@implementation KCDDiscreteViewController {
    IOSKnobControl* knobControl;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // basic IOSKnobControl initialization (using default settings) with an image from the bundle
    knobControl = [[IOSKnobControl alloc] initWithFrame:self.knobControlView.bounds /* imageNamed:@"hexagon-ccw" */];

    // arrange to be notified whenever the knob turns
    [knobControl addTarget:self action:@selector(knobPositionChanged:) forControlEvents:UIControlEventValueChanged];

    // Now hook it up to the demo
    [self.knobControlView addSubview:knobControl];

    [self updateKnobProperties];
}

- (void)adjustLayout
{
    [super adjustLayout];
    [knobControl setNeedsLayout];
}

#pragma mark - Knob control callback

- (void)knobPositionChanged:(IOSKnobControl*)sender
{
    self.positionLabel.text = [NSString stringWithFormat:@"%.2f", knobControl.position];
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)knobControl.positionIndex];
}

#pragma mark - Handlers for configuration controls

- (void)somethingChanged:(id)sender
{
    [self updateKnobProperties];
}

- (void)clockwiseChanged:(UISwitch *)sender
{
    if (self.useHexagonImages) {
        [knobControl setImage:self.hexagonImage forState:UIControlStateNormal];
    }
    [self updateKnobProperties];
}

#pragma mark - Internal methods

- (void)updateKnobProperties
{
    knobControl.mode = self.modeControl.selectedSegmentIndex == 0 ? IKCModeLinearReturn : IKCModeWheelOfFortune;

    if (self.useHexagonImages) {
        knobControl.positions = 6;
        [knobControl setImage:self.hexagonImage forState:UIControlStateNormal];
    }
    else {
        knobControl.positions = 12;
        knobControl.titles = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
        [knobControl setImage:nil forState:UIControlStateNormal];
    }

    knobControl.circular = YES;
    knobControl.clockwise = self.clockwiseSwitch.on;
    knobControl.gesture = IKCGestureOneFingerRotation + self.gestureControl.selectedSegmentIndex;

    // knobControl.fontName = @"CourierNewPS-BoldMT";
    knobControl.fontName = @"Menlo-Bold";
    // knobControl.fontName = @"Georgia-Bold";
    // knobControl.fontName = @"TimesNewRomanPS-BoldMT";
    // knobControl.fontName = @"AvenirNext-Bold";
    // knobControl.fontName = @"TrebuchetMS-Bold";

    // tint and title colors
    if ([knobControl respondsToSelector:@selector(setTintColor:)]) {
        knobControl.tintColor = [UIColor greenColor];
    }

    UIColor* titleColor = [UIColor whiteColor];
    [knobControl setTitleColor:titleColor forState:UIControlStateNormal];
    [knobControl setTitleColor:titleColor forState:UIControlStateHighlighted];

    /*
     * Using exponentiation avoids compressing the scale below 1.0. The
     * slider starts at 0 in middle and ranges from -1 to 1, so the
     * time scale can range from 1/e to e, and defaults to 1.
     */
    knobControl.timeScale = exp(self.timeScaleControl.value);

    // Good idea to do this to make the knob reset itself after changing certain params.
    knobControl.position = knobControl.position;
}

- (UIImage*)hexagonImage
{
    return [UIImage imageNamed:self.clockwiseSwitch.on ? @"hexagon-cw" : @"hexagon-ccw"];
}

- (BOOL)useHexagonImages
{
    return _demoControl.selectedSegmentIndex > 0;
}

@end