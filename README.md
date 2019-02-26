# Command Buffer based Refraction shaders for Unity

**Adjustable, blurred Refraction shaders** created with Amplify Shader Editor using **Command Buffers**. Cool to create **glass like materials**. **Works without Amplify Shader Editor**. Inspired by an [Unity blog entry](https://blogs.unity3d.com/2015/02/06/extending-unity-5-rendering-pipeline-command-buffers). 

This implementation was initially created for use in **[Pizza Connection 3](https://store.steampowered.com/app/588160/Pizza_Connection_3/)**, but I adapted the approach for general usage.

# Goal
To create **cool looking glass materials** it's nice to have **refraction** on the surfaces. In recent games, glass materials sometimes also feature a dynamic blurred refraction on their surface.

See the new **DOOM** for example:

![](http://www.adriancourreges.com/img/blog/2016/doom2016/shot/70_glass_after.jpg)

To achieve this effect in Unity the [classical approach](https://forum.unity.com/threads/simple-optimized-blur-shader.185327/) is to use a GrabPass in your shader & blur several instances of the same screen based texture. Since **Unity 5** there is an alternative to this approach using [CommandBuffers](https://docs.unity3d.com/ScriptReference/Rendering.CommandBuffer.html). See [this blog entry](https://blogs.unity3d.com/2015/02/06/extending-unity-5-rendering-pipeline-command-buffers/) for more detail. *TL;DR: Using Command buffers is more performant, flexible and easier to use than a normal grab pass in the above case.*

Since I haven't found any sources except the Unity blog entry on how to achieve the desired effect using Command Buffers I implemented it on my own by adapting the [example provided by Unity](https://blogs.unity3d.com/wp-content/uploads/2015/02/RenderingCommandBuffers50b22.zip). To create the main shaders I used the Amplify Shader Editor *(ASE)*.

**Disclaimer:** I'm no expert in Shader/Graphics Programming, I just felt the urge to contribute and help others. Everyone is encouraged to contribute to this project and make it better. :)

### Screenshots
The blur amount can be tweaked as a simple float property.
![](https://user-images.githubusercontent.com/530629/30776705-77c565b4-a0ab-11e7-9fac-3d61d49e6190.png)
Reflectivity, Distortion, Emission contribution and a lot of other things can be tweaked.
![](https://user-images.githubusercontent.com/530629/30776643-6e7278d6-a0aa-11e7-93be-ac8fd8c9404b.png)

### Usage
1. **Copy the contents** of this repository into your **Unity project**.
2. Add **GrabScreen.cs** to the **camera** you want to capture the screen from. *(This creates 2 global screen textures for our shaders: Blur & No Blur)*
3. Create a new **Material** and use one of the CommandBufferRefraction shaders, found under **Custom/CommandBufferRefraction** or **Custom/CommandBufferRefractionCheaper**
4. **Apply your material** to a renderer in your scene.
5. **Press play** & watch the material in the **Game View**

### Options

#### *RefractionWithCommandBuffer.shader*
![](https://user-images.githubusercontent.com/530629/30776719-ad4a96fa-a0ab-11e7-91c4-17881574ab7a.png)

*Note: To give maximum flexibility 3 textures are used to define the material. The property name already shows you which channels of the texture are used for which purpose.*

### *RefractionWithCommandBufferCheaper.shader*
![](https://user-images.githubusercontent.com/530629/30776716-9c4a5a48-a0ab-11e7-9c64-727bf59c4401.png)

*Note: This is the more easy to use, faster version of the shader (less texture calls). A lot of the properties are tweaked by using sliders.*

### ASE Graphs
The shader was created using the Amplify Shader Editor from the Asset Store. Luckily, **you can use these shaders without this asset**. However if you have the shader editor you can directly open the shaders in ASE.

*Below be shader graphs:*
The CommandBufferRefractionShader.
![CommandBufferRefraction.shader](https://user-images.githubusercontent.com/530629/30776913-a0a9b4ea-a0af-11e7-886b-46abddbddd29.png)
The cheaper version (fewer texture calls).
![CommandBufferRefractionCheaper.shader](https://user-images.githubusercontent.com/530629/30776943-0914538c-a0b0-11e7-9f6f-9909814b7fbd.png)

### Caveats
![](https://user-images.githubusercontent.com/530629/30776669-d7a65b7e-a0aa-11e7-9b31-23a82dfeadae.png)
- **Unity Editor:** Shaders don't preview correctly in the *Scene View*
- **Performance:** We create 2 global textures with the command buffer (blurred and non blurred), they are smaller than the actual camera screen size, but this is still performance heavy, so watch out.
- **Forward Based:** We need to render in the transparent queue, so this shader works only with forward rendering.
