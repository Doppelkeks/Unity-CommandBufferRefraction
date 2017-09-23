using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// ----------
/// GrabScreen - Command Buffer script
/// This script creates two global textures containing the screen. Blurred and non-blurred.
/// These textures can be used by e.g. refraction shaders to work without a grab pass.
/// Inspired & adapted by: https://blogs.unity3d.com/2015/02/06/extending-unity-5-rendering-pipeline-command-buffers/
/// 
/// INSTRUCTIONS: Put this script on the camera you want to capture the screen from.
/// ----------
/// </summary>
[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class GrabScreen : MonoBehaviour{

    /// <summary>
    /// The shader used to blur the screen.
    /// </summary>
    public Shader blurShader;

    /// <summary>
    /// Strings used for shader property identification...
    /// </summary>
    private const string
        cBufferName = "GrabAndBlurScreen",
        screenCopyKey = "_ScreenCopyTexture",
        blurredIDKey = "_Temp1",
        blurredID2Key = "_Temp2",
        offsetsKey = "offsets",
        globalBlurKey = "_GrabBlurTexture",
        globalNoBlurKey = "_GrabNoBlurTexture",
        blurShaderKey = "Hidden/SeparableBlur";

    /// <summary>
    /// Which camera event the command buffer should be attached to.
    /// </summary>
    private CameraEvent _cameraEvent = CameraEvent.AfterImageEffectsOpaque;
    /// <summary>
    /// The texture filter mode of the created render textures.
    /// </summary>
    private FilterMode _filterMode = FilterMode.Bilinear;
    /// <summary>
    /// Reference to the material we are using
    /// </summary>
    private Material _material;
    /// <summary>
    /// Screen resolution. Used to check if the screen size changed.
    /// </summary>
    private Resolution _currentScreenRes = new Resolution();
    /// <summary>
    /// Reference to our command buffer.
    /// </summary>
    private CommandBuffer _cBuffer;
    /// <summary>
    /// reference to our attached camera.
    /// </summary>
    private Camera _camera;
    /// <summary>
    /// Shader property IDs (automatically set)
    /// </summary>
    private int _screenCopyID, _blurredID, _blurredID2;

    /// <summary>
    /// Attached camera getter (read only)
    /// </summary>
    private Camera Camera {
        get {
            GetCamera();
            return _camera;
        }
    }

    /// <summary>
    /// Creates the command buffer.
    /// </summary>
    private void CreateCommandBuffer() {
        DestroyCommandBuffer();
        Initialize();

        // Create CommandBuffer
        _cBuffer = new CommandBuffer();
        _cBuffer.name = cBufferName;
        _cBuffer.Clear();

        // copy screen into temporary RT (-2 means half the screen size)
        _cBuffer.GetTemporaryRT(_screenCopyID, -2, -2, 0, _filterMode);
        _cBuffer.Blit(BuiltinRenderTextureType.CurrentActive, _screenCopyID);
        _cBuffer.SetGlobalTexture(globalNoBlurKey, _screenCopyID);

        // get two smaller RTs (-4 means quad the screen size)
        _cBuffer.GetTemporaryRT(_blurredID, -4, -4, 0, _filterMode);
        _cBuffer.GetTemporaryRT(_blurredID2, -4, -4, 0, _filterMode);

        // downsample screen copy into smaller RT, release screen RT
        _cBuffer.Blit(_screenCopyID, _blurredID);
        _cBuffer.ReleaseTemporaryRT(_screenCopyID);

        // horizontal blur
        _cBuffer.SetGlobalVector(offsetsKey, new Vector4(2.0f / Screen.width, 0, 0, 0));
        _cBuffer.Blit(_blurredID, _blurredID2, _material);
        // vertical blur
        _cBuffer.SetGlobalVector(offsetsKey, new Vector4(0, 2.0f / Screen.height, 0, 0));
        _cBuffer.Blit(_blurredID2, _blurredID, _material);
        // horizontal blur
        _cBuffer.SetGlobalVector(offsetsKey, new Vector4(4.0f / Screen.width, 0, 0, 0));
        _cBuffer.Blit(_blurredID, _blurredID2, _material);
        // vertical blur
        _cBuffer.SetGlobalVector(offsetsKey, new Vector4(0, 4.0f / Screen.height, 0, 0));
        _cBuffer.Blit(_blurredID2, _blurredID, _material);

        _cBuffer.SetGlobalTexture(globalBlurKey, _blurredID);
        Camera.AddCommandBuffer(_cameraEvent, _cBuffer);
    }

    /// <summary>
    /// Destroys the command buffer.
    /// </summary>
    private void DestroyCommandBuffer() {
        if (_cBuffer != null) {
            Camera.RemoveCommandBuffer(_cameraEvent, _cBuffer);
            _cBuffer.Clear();
            _cBuffer.Dispose();
            _cBuffer = null;
        }

        // Make sure we don't have any duplicates of our command buffer.
        CommandBuffer[] commandBuffers = Camera.GetCommandBuffers(_cameraEvent);
        foreach (CommandBuffer cBuffer in commandBuffers) {
            if (cBuffer.name == cBufferName) {
                Camera.RemoveCommandBuffer(_cameraEvent, cBuffer);
                cBuffer.Clear();
                cBuffer.Dispose();
            }
        }
    }

    // Update is called once per frame
    private void OnPreRender() {
        //Recreate command buffer if screen size, downsample or blur was (de)activated
        if (_currentScreenRes.height != Camera.pixelHeight || _currentScreenRes.width != Camera.pixelWidth) {
            SetCurrentValues();
            CreateCommandBuffer();
        }
        SetCurrentValues();
    }

    /// <summary>
    /// Sets the current values.
    /// </summary>
    private void SetCurrentValues() {
        _currentScreenRes.height = Camera.pixelHeight;
        _currentScreenRes.width = Camera.pixelWidth;
    }

    /// <summary>
    /// Initialize stuff.
    /// </summary>
    private void OnEnable() {
        Initialize();
    }

    /// <summary>
    /// Initialize shader, material, camera 
    /// </summary>
    private void Initialize() {
        // If the blur shader isn't initialized, try to find it.
        if (!blurShader) {
            blurShader = Shader.Find(blurShaderKey);
        }

        // if no material was created with the blur shader yet, create one.
        if (!_material) {
            _material = new Material(blurShader);
            _material.hideFlags = HideFlags.HideAndDontSave;
        }

        // convert shader property keywords into IDs.
        _screenCopyID = Shader.PropertyToID(screenCopyKey);
        _blurredID = Shader.PropertyToID(blurredIDKey);
        _blurredID2 = Shader.PropertyToID(blurredID2Key);

        // get our attached camera.
        GetCamera();
    }

    /// <summary>
    /// Gets the attached camera.
    /// </summary>
    private void GetCamera() {
        if (!_camera) {
            _camera = GetComponent<Camera>();
        }
    }
}
