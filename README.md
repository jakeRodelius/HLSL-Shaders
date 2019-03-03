# HLSL-Shaders
Some of the HLSL shaders I've written for Unity.

Mask Line Shader:

This shader reveals a texture with a wipe, this is great to use as a video transition. This is a good example of the kind of math I use in shaders.


UI Saturation Shader:

This shader is used on UI elements and allows the editing of the saturation of the texture. This is a small edit to the default UI texture but I thought this was a useful tool and elegant solution.


Mask Texture Directional Shader:

This is the most complex of these shaders, the idea is to only be able to see a face of the geometry if it is facing the right direction. This geometry is also a mask for a screen space texture. 

The Mask Texture Directional Shader looks like this:

![An example gif of the directional shader](https://github.com/jakeRodelius/HLSL-Shaders/blob/master/directionalMask.gif?raw=true)
