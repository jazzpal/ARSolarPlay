//
//  SCNViewController.m
//  ARSolarPlay
//
//  Created by Jaspal Sawhney on 8/31/17.
//  Copyright © 2017 Jaspal Sawhney. All rights reserved.
//


#import "SCNViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface SCNViewController ()<ARSCNViewDelegate,ARSessionDelegate>
@property (nonatomic, strong)ARSCNView *arSCNView;
@property(nonatomic,strong)ARSession *arSession;

@property(nonatomic,strong)ARSessionConfiguration *arSessionConfiguration;

//Nodes
@property(nonatomic, strong) SCNNode *sunNode;
@property(nonatomic, strong) SCNNode *earthNode;
@property(nonatomic, strong) SCNNode *moonNode;
@property(nonatomic, strong) SCNNode *earthGroupNode;
@property(nonatomic, strong) SCNNode *sunHaloNode;
@end

@implementation SCNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.view addSubview:self.arSCNView];
    self.arSCNView.delegate = self;
    
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNode{
    
    _sunNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    
    //size of the planets
    _sunNode.geometry = [SCNSphere sphereWithRadius:0.30];
    _earthNode.geometry = [SCNSphere sphereWithRadius:0.15];
    _moonNode.geometry = [SCNSphere sphereWithRadius:0.10];
    
    //distance between the earth and moon
    _moonNode.position = SCNVector3Make(.50, 0, 0);
    [_earthGroupNode addChildNode:_earthNode];
    
    _earthGroupNode.position = SCNVector3Make(1.0, 0, 0);
    [_sunNode setPosition:SCNVector3Make(0, -0.1, 3)];
    [self.arSCNView.scene.rootNode addChildNode:_sunNode];
    
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
    
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS  =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
    
    _earthNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _moonNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
    
    _earthNode.geometry.firstMaterial.shininess =
    _moonNode.geometry.firstMaterial.shininess = 0.1;
    _earthNode.geometry.firstMaterial.specular.intensity =
    _moonNode.geometry.firstMaterial.specular.intensity = 0.5;
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor grayColor];
    
    [self roationNode];
    [self addOtherNode];
    [self addLight];
    
}

-(void)roationNode{
    
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // Rotate the moon
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 50;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [_moonNode addAnimation:animation forKey:@"moon rotation"];
    
    // Moon-rotation (center of rotation of the Moon around the Earth)
    SCNNode *moonRotationNode = [SCNNode node];
    
    [moonRotationNode addChildNode:_moonNode];
    
    // Rotate the moon around the Earth
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 50.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:animation forKey:@"moon rotation around earth"];
    
    [_earthGroupNode addChildNode:moonRotationNode];
    
    // Earth-rotation (center of rotation of the Earth around the Sun)
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    
    // Earth-group (will contain the Earth, and the Moon)
    [earthRotationNode addChildNode:_earthGroupNode];
    
    // Rotate the Earth around the Sun
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 50.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
    

    [self addAnimationToSun];
}

-(void)addAnimationToSun{
    
    // Achieve a lava effect by animating textures
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 30.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
    
}

-(void)mathRoation{
    
    // custom Action
    
    float totalDuration = 10.0f;
    float duration = totalDuration/360;
    
    
    SCNAction *customAction = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime){
        if(elapsedTime == duration){
            SCNVector3 position = node.position;
            
            float rx0 = 0;
            float ry0 = 0;
            
            float angle = 1.0f/180*M_PI;
            
            float x =  (position.x - rx0)*cos(angle) - (position.z - ry0)*sin(angle) + rx0 ;
            
            float z = (position.x - rx0)*sin(angle) + (position.z - ry0)*cos(angle) + ry0 ;
            
            node.position = SCNVector3Make(x, node.position.y, z);
            
        }
        
    }];
    
    SCNAction *repeatAction = [SCNAction repeatActionForever:customAction];
    
    [_earthGroupNode runAction:repeatAction];
}

-(void)addLight{
    
    // We will turn off all the lights in the scene and add a new light
    // to give the impression that the Sun lights the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor blackColor]; // initially switched off
    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    
    // Configure attenuation distances because we don't want to light the floor
    lightNode.light.attenuationEndDistance = 19;
    lightNode.light.attenuationStartDistance = 21;
    
    // Animation
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
        lightNode.light.color = [UIColor whiteColor]; // switch on
        //[presentationViewController updateLightingWithIntensities:@[@0.0]]; //switch off all the other lights
        _sunHaloNode.opacity = 0.5; // make the halo stronger
    }
    [SCNTransaction commit];
    
}

- (void)addOtherNode{
    
    SCNNode *cloudsNode = [SCNNode node];
    cloudsNode.geometry = [SCNSphere sphereWithRadius:0.06];
    [_earthNode addChildNode:cloudsNode];
    
    cloudsNode.opacity = 0.5;
    // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
    cloudsNode.geometry.firstMaterial.transparent.contents = @"art.scnassets/earth/cloudsTransparency.png";
    cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
    
    // Add a halo to the Sun (a simple textured plane that does not write to depth)
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:2.5 height:2.5];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
    _sunHaloNode.opacity = 0.2;
    [_sunNode addChildNode:_sunHaloNode];
    
     // Add a textured plane to represent Earth's orbit
    SCNNode *earthOrbit = [SCNNode node];
    earthOrbit.opacity = 0.4;
    earthOrbit.geometry = [SCNBox boxWithWidth:1.72 height:0 length:1.72 chamferRadius:0];
    earthOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    earthOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    [_sunNode addChildNode:earthOrbit];
    
    // Add a textured plane to represent Moon's orbit
    SCNNode *moonOrbit = [SCNNode node];
    moonOrbit.opacity = 0.2;
    moonOrbit.geometry = [SCNBox boxWithWidth:0.86 height:0 length:0.86 chamferRadius:0];
    moonOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    moonOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    moonOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    moonOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
    [_earthNode addChildNode:moonOrbit];
    
}

- (ARSessionConfiguration *)arSessionConfiguration
{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    
    ARWorldTrackingSessionConfiguration *configuration = [[ARWorldTrackingSessionConfiguration alloc] init];
    
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    
    _arSessionConfiguration.lightEstimationEnabled = YES;
    return _arSessionConfiguration;
}

- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    return _arSession;
}

- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    _arSCNView.delegate = self;
    
    [self initNode];
    
    return _arSCNView;
}

#pragma mark -ARSessionDelegate

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{

    [_sunNode setPosition:SCNVector3Make(-3 * frame.camera.transform.columns[3].x, -0.1 - 3 * frame.camera.transform.columns[3].y, -2 - 3 * frame.camera.transform.columns[3].z)];
}

@end


